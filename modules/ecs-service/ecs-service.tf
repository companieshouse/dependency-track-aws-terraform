resource "aws_ecs_service" "ecs-service" {
  name                              = "${var.environment}-${var.service_name}"
  cluster                           = var.ecs_cluster_id
  task_definition                   = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count                     = var.desired_task_count
  wait_for_steady_state             = var.wait_for_steady_state
  enable_execute_command            = var.enable_execute_command && length(var.task_role_arn) > 0
  health_check_grace_period_seconds = local.lb_health_check_grace_period_seconds
  launch_type                       = var.use_fargate ? "FARGATE" : var.use_capacity_provider ? null : "EC2"
  propagate_tags                    = var.propagate_tags
  tags                              = local.default_tags


  dynamic "load_balancer" {
    for_each = local.create_lb_target_group ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.ecs-target-group[0].arn
      container_port   = local.traffic_port
      container_name   = local.load_balancer_target_container
    }
  }

  dynamic "load_balancer" {
    for_each = aws_lb_target_group.multilb-ecs-target-group
    content {
      target_group_arn = load_balancer.value.arn
      container_port   = local.traffic_port
      container_name   = local.load_balancer_target_container
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.use_capacity_provider && !var.use_fargate ? [""] : []
    content {
      weight            = 100
      capacity_provider = "capacity-provider-${var.name_prefix}"
    }
  }

  # dynamic network_configuration block type required here to ensure it is only defined when using fargate
  dynamic "network_configuration" {
    for_each = var.use_fargate ? [""] : []
    content {
      subnets         = var.fargate_subnets
      security_groups = [aws_security_group.ecs_service_fargate_sg[0].id]
    }
  }
}


resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "${var.environment}-${var.service_name}"
  requires_compatibilities = var.use_fargate ? ["FARGATE"] : ["EC2"]
  network_mode             = var.use_fargate ? "awsvpc" : null
  cpu                      = var.use_eric_reverse_proxy ? var.required_cpus + var.eric_cpus : var.total_service_cpu > 0 ? var.total_service_cpu : var.required_cpus
  memory                   = var.use_eric_reverse_proxy ? var.required_memory + var.eric_memory : var.total_service_memory > 0 ? var.total_service_memory : var.required_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = length(var.task_role_arn) > 0 ? var.task_role_arn : null
  container_definitions    = jsonencode(local.container_definitions)
  tags                     = local.default_tags


  # dynamic runtime_platform block type required here to ensure it is only defined when using fargate
  dynamic "runtime_platform" {
    for_each = var.use_fargate ? [""] : []
    content {
      operating_system_family = "LINUX"
      cpu_architecture        = "X86_64"
    }
  }

  dynamic "volume" {
    for_each = var.volumes

    content {
      dynamic "docker_volume_configuration" {
        for_each = try([volume.value.docker_volume_configuration], [])

        content {
          autoprovision = try(docker_volume_configuration.value.autoprovision, null)
          driver        = try(docker_volume_configuration.value.driver, null)
          driver_opts   = try(docker_volume_configuration.value.driver_opts, null)
          labels        = try(docker_volume_configuration.value.labels, null)
          scope         = try(docker_volume_configuration.value.scope, null)
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = try([volume.value.efs_volume_configuration], [])

        content {
          dynamic "authorization_config" {
            for_each = try([efs_volume_configuration.value.authorization_config], [])

            content {
              access_point_id = try(authorization_config.value.access_point_id, null)
              iam             = try(authorization_config.value.iam, null)
            }
          }

          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = try(efs_volume_configuration.value.root_directory, null)
          transit_encryption      = try(efs_volume_configuration.value.transit_encryption, null)
          transit_encryption_port = try(efs_volume_configuration.value.transit_encryption_port, null)
        }
      }

      host_path = try(volume.value.host_path, null)
      name      = try(volume.value.name, volume.key)
    }
  }
}

resource "aws_lb_target_group" "ecs-target-group" {
  count = local.create_lb_target_group ? 1 : 0

  name        = var.use_fargate ? local.target_group_name_fargate : local.target_group_name
  port        = local.traffic_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.use_fargate ? "ip" : "instance"
  tags        = local.default_tags

  health_check {
    healthy_threshold   = var.healthcheck_healthy_threshold
    unhealthy_threshold = var.healthcheck_unhealthy_threshold
    interval            = var.healthcheck_interval
    matcher             = var.healthcheck_matcher
    path                = var.healthcheck_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "lb-listener-rule" {
  for_each = local.create_lb_listener_rule ? {
    for idx, list in local.lb_listener_path_lists : idx => list
  } : {}

  listener_arn = var.lb_listener_arn
  priority     = local.lb_listener_rule_priority_amped + each.key
  tags         = local.default_tags

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-target-group[0].arn
  }
  condition {
    path_pattern {
      values = each.value
    }
  }
}

# Auto Scaling
resource "aws_appautoscaling_target" "target" {
  count = var.service_autoscale_enabled ? 1 : 0

  max_capacity       = var.max_task_count
  min_capacity       = var.min_task_count
  resource_id        = "service/${local.ecs_cluster_name}/${aws_ecs_service.ecs-service.name}"
  role_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count = var.service_autoscale_enabled && var.service_autoscale_target_value_cpu < 100 ? 1 : 0

  name               = "target-scaling-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.service_autoscale_target_value_cpu
    scale_in_cooldown  = var.service_autoscale_scale_in_cooldown
    scale_out_cooldown = var.service_autoscale_scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_mem" {
  count = var.service_autoscale_enabled && var.service_autoscale_target_value_mem < 100 ? 1 : 0

  name               = "target-scaling-mem"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.service_autoscale_target_value_mem
    scale_in_cooldown  = var.service_autoscale_scale_in_cooldown
    scale_out_cooldown = var.service_autoscale_scale_out_cooldown
  }
}

resource "aws_appautoscaling_scheduled_action" "schedule-scaleup" {
  count = var.service_autoscale_enabled && length(var.service_scaleup_schedule) > 0 ? 1 : 0

  name               = "${var.environment}-${var.service_name}-schedule-scaleup"
  service_namespace  = aws_appautoscaling_target.target[0].service_namespace
  resource_id        = aws_appautoscaling_target.target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.target[0].scalable_dimension
  schedule           = "cron(${var.service_scaleup_schedule})"
  timezone           = "Europe/London"

  scalable_target_action {
    min_capacity = var.min_task_count
    max_capacity = var.max_task_count
  }
}

resource "aws_appautoscaling_scheduled_action" "schedule-scaledown" {
  count = var.service_autoscale_enabled && length(var.service_scaledown_schedule) > 0 ? 1 : 0

  name               = "${var.environment}-${var.service_name}-schedule-scaledown"
  service_namespace  = aws_appautoscaling_target.target[0].service_namespace
  resource_id        = aws_appautoscaling_target.target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.target[0].scalable_dimension
  schedule           = "cron(${var.service_scaledown_schedule})"
  timezone           = "Europe/London"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}
