locals {
  multilb_listener_path_lists = var.enable_listener ? chunklist(var.lb_listener_paths, 5) : []
  # Combining listeners and rules to create listener rules
  multilb_listener_rules = flatten([
    for listener, listener_data in var.multilb_listeners : [
      for chunk in local.multilb_listener_path_lists : {
        listener = listener
        list     = chunk
        arn      = listener_data.listener_arn
      }
    ]
  ])

  security_group_ids = flatten([for i in range(length(var.multilb_listeners)) : data.aws_lb.multilb[i].security_groups])
}

resource "aws_lb_target_group" "multilb-ecs-target-group" {
  for_each    = var.multilb_listeners
  name = endswith(substr("${var.environment}-${each.key}-${var.service_name}", 0, 32), "-") ? substr("${var.environment}-${each.key}-${var.service_name}", 0, 31) : substr("${var.environment}-${each.key}-${var.service_name}", 0, 32)
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
resource "aws_lb_listener_rule" "multilb-listener-rule" {
  for_each = { for idx, data in local.multilb_listener_rules : idx => data }

  listener_arn = each.value.arn
  priority     = local.lb_listener_rule_priority_amped + each.key
  tags         = local.default_tags

  dynamic "condition" {
    for_each = each.value.list
    content {
      path_pattern {
        values = each.value.list
      }
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.multilb-ecs-target-group[each.value.listener].arn
  }
}


resource "aws_security_group_rule" "ingress_multilb_security_groups" {
  count = var.use_fargate ? min(var.multilb_max_rules, length(var.multilb_listeners)) : 0

  description              = "Ingress from ${local.security_group_ids[count.index]}"
  type                     = "ingress"
  from_port                = local.traffic_port
  to_port                  = local.traffic_port
  protocol                 = "tcp"
  source_security_group_id = element(local.security_group_ids, count.index)
  security_group_id        = aws_security_group.ecs_service_fargate_sg[0].id
}

resource "aws_cloudwatch_metric_alarm" "multilb_unhealthy_host_count" {
  for_each = var.multilb_cloudwatch_alarms_enabled && var.cloudwatch_unhealthy_host_count_enabled ? aws_lb_target_group.multilb-ecs-target-group : {}

  alarm_name          = "${local.ecs_cluster_name}-tg-${var.service_name}-${each.key}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_unhealthy_host_count_number_of_periods
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_unhealthy_host_count_period
  statistic           = "Minimum"
  threshold           = var.cloudwatch_unhealthy_host_count_threshold
  alarm_description   = format("Unhealthy host count is greater than %s", var.cloudwatch_unhealthy_host_count_threshold)
  alarm_actions       = local.cloudwatch_sns_topics
  ok_actions          = local.cloudwatch_sns_topics
  treat_missing_data  = "notBreaching"

  dimensions = {
    "TargetGroup"  = each.value.arn_suffix
    "LoadBalancer" = var.multilb_listeners[each.key].load_balancer_arn
  }

  depends_on = [
    aws_lb_target_group.multilb-ecs-target-group
  ]
}

resource "aws_cloudwatch_metric_alarm" "multilb_healthy_host_count" {
  for_each = var.multilb_cloudwatch_alarms_enabled && var.cloudwatch_unhealthy_host_count_enabled ? aws_lb_target_group.multilb-ecs-target-group : {}

  alarm_name          = "${local.ecs_cluster_name}-tg-${var.service_name}-${each.key}-healthy-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.cloudwatch_healthy_host_count_number_of_periods
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_healthy_host_count_period
  statistic           = "Maximum"
  threshold           = var.cloudwatch_healthy_host_count_threshold
  alarm_description   = format("Healthy host count is less than %s", var.cloudwatch_healthy_host_count_threshold)
  alarm_actions       = local.cloudwatch_sns_topics
  ok_actions          = local.cloudwatch_sns_topics
  treat_missing_data  = "breaching"

  dimensions = {
    "TargetGroup"  = each.value.arn_suffix
    "LoadBalancer" = var.multilb_listeners[each.key].load_balancer_arn
  }

  depends_on = [
    aws_lb_target_group.multilb-ecs-target-group
  ]
}

resource "aws_cloudwatch_metric_alarm" "multilb_response_time" {
  for_each = var.multilb_cloudwatch_alarms_enabled && var.cloudwatch_response_time_enabled ? aws_lb_target_group.multilb-ecs-target-group : {}

  alarm_name          = "${local.ecs_cluster_name}-tg-${var.service_name}-${each.key}-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_response_time_number_of_periods
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_response_time_period
  statistic           = "Average"
  threshold           = var.cloudwatch_response_time_threshold
  alarm_description   = format("Response time is greater than %s", var.cloudwatch_response_time_threshold)
  alarm_actions       = local.cloudwatch_sns_topics
  ok_actions          = local.cloudwatch_sns_topics
  treat_missing_data  = "notBreaching"

  dimensions = {
    "TargetGroup"  = each.value.arn_suffix
    "LoadBalancer" = var.multilb_listeners[each.key].load_balancer_arn
  }

  depends_on = [
    aws_lb_target_group.multilb-ecs-target-group
  ]
}

resource "aws_cloudwatch_metric_alarm" "multilb_http_5xx_error_count" {
  for_each = var.multilb_cloudwatch_alarms_enabled && var.cloudwatch_http_5xx_error_count_enabled ? aws_lb_target_group.multilb-ecs-target-group : {}


  alarm_name          = "${local.ecs_cluster_name}-tg-${var.service_name}-${each.key}-5xx-error-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_http_5xx_error_count_number_of_periods
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_http_5xx_error_count_period
  statistic           = "Maximum"
  threshold           = var.cloudwatch_http_5xx_error_count_threshold
  alarm_description   = format("5xx error count is greater than %s", var.cloudwatch_http_5xx_error_count_threshold)
  alarm_actions       = local.cloudwatch_sns_topics
  ok_actions          = local.cloudwatch_sns_topics
  treat_missing_data  = "notBreaching"

  dimensions = {
    "TargetGroup"  = each.value.arn_suffix
    "LoadBalancer" = var.multilb_listeners[each.key].load_balancer_arn
  }

  depends_on = [
    aws_lb_target_group.multilb-ecs-target-group
  ]
}
