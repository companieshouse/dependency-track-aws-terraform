locals {
  ecs_cluster_name = var.ecs_cluster_name == "" ? "${var.name_prefix}-cluster" : var.ecs_cluster_name

  default_tags = merge(var.default_tags,
    {
      ServiceName        = var.service_name
      ECSClusterName     = local.ecs_cluster_name
      Environment        = var.environment
      UseFargate         = var.use_fargate
      ManagedByTerraform = "true"
    }
  )

  # Shortening the target_group_name in case it's over the 32 char max
  full_target_group_name    = var.use_eric_reverse_proxy ? "${var.environment}-${var.service_name}-eric" : "${var.environment}-${var.service_name}"
  target_group_name         = length(local.full_target_group_name) > 32 ? substr(local.full_target_group_name, 0, 32) : local.full_target_group_name
  target_group_name_fargate = length(local.full_target_group_name) > 28 ? format("%s%s", substr(local.full_target_group_name, 0, 28), "-far") : "${local.full_target_group_name}-far"

  lb_listener_path_lists          = var.enable_listener ? chunklist(var.lb_listener_paths, 5) : []
  lb_listener_rule_priority_amped = var.lb_listener_rule_priority * 10

  # when using fargate the tasks host port must match the tasks container port, same for eric when its used
  task_host_port = var.use_fargate ? var.container_port : 0
  eric_host_port = var.use_fargate ? var.eric_port : 0

  # when using eric as a reverse proxy traffic needs to be sent to eric which then forwards to the task container or when target container port supplied use this one
  traffic_port = var.use_eric_reverse_proxy ? var.eric_port : var.target_container_port > 0 ? var.target_container_port : var.container_port

  # set proxy bypass paths to ensure healthchecks can get through eric without auth checks,
  # if extra proxy bypass paths are set then append them to the healthcheck bypass path with the "|" char as a separator
  eric_proxy_bypass_paths = var.eric_extra_bypass_paths == "" ? var.healthcheck_path : "${var.healthcheck_path}|${var.eric_extra_bypass_paths}"

  # when using fargate localhost must be used to forward to task container, ec2 requires service_name as the domain
  eric_proxy_target_domain = var.use_fargate ? "localhost" : var.service_name

  # elements of eric env need to be set per service, if eric is in use set them here based off other vars passed in
  updated_eric_environment = var.use_eric_reverse_proxy ? concat(
    var.eric_environment,
    [
      # set the eric port so traffic from the target group hits eric correctly
      { "name" : "PORT", "value" : "${var.eric_port}" },
      # set the proxy target to the service sat behind eric on the correct port, service_name is used for local docker communication
      { "name" : "PROXY_TARGET_URLS", "value" : "http://${local.eric_proxy_target_domain}:${var.container_port}" },
      # set the proxy bypass paths constructed above from the healthcheck and extra bypass paths
      { "name" : "PROXY_BYPASS_PATHS", "value" : local.eric_proxy_bypass_paths }
    ]
  ) : []

  healthcheck_definition = var.use_task_container_healthcheck ? local.task_container_healthcheck_definition : ""
  # use_task_container_healthcheck
  task_container_healthcheck_definition = <<DEFINITION
            "healthCheck": {
              "command": [
                  "CMD-SHELL",
                  "[[ $(curl http://localhost:${var.container_port}${var.healthcheck_path} -o /dev/null -w '%%{http_code}\n' -s) == '${var.healthcheck_matcher}' ]] || exit 1"
              ],
              "interval": 30,
              "timeout": 5,
              "retries": 3
            },
        DEFINITION

  # s3 env files prefix
  s3_config_bucket            = data.vault_generic_secret.shared_s3.data["config_bucket_name"]
  environment_file_arn_prefix = var.use_set_environment_files ? "arn:aws:s3:::${local.s3_config_bucket}/ecs-service-configs/${var.aws_profile}/${var.environment}" : ""

  # build environment files for task definition 
  environment_file_array = var.use_set_environment_files ? [{
    "value" : "${local.environment_file_arn_prefix}/generated-${var.app_environment_filename}",
    "type" : "s3"
  }] : var.environment_files

  # the task container definition contains config for the ecs service app itself
  task_container_definition = <<DEFINITION
        {
            "environment": ${jsonencode(var.task_environment)},
            "environmentFiles": ${jsonencode(local.environment_file_array)},
            "name": "${var.service_name}",
            "image": "${var.docker_registry}/${var.docker_repo}:${var.container_version}",
            "cpu": ${var.required_cpus},
            "memory": ${var.required_memory},
            "mountPoints": ${jsonencode(var.mount_points)},
            "portMappings": [{
                "containerPort": ${var.container_port},
                "hostPort": ${local.task_host_port},
                "protocol": "tcp"
            }],
            ${local.healthcheck_definition}
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-region": "${var.aws_region}",
                    "awslogs-group": "/ecs/${var.name_prefix}/${var.service_name}",
                    "awslogs-stream-prefix": "ecs"
                }
            },
            "secrets": ${jsonencode(var.task_secrets)},
            "volumesFrom": [],
            "essential": true,
            "ulimits": ${jsonencode(var.ulimits)}
          }
    DEFINITION

  # links block cannot be defined when using fargate with network mode awsvpc but needs to be defined for ec2 launch type networking between eric and task container
  eric_links = var.use_fargate ? [] : [var.service_name]

  # build environment files for task definition
  eric_environment_file_array = var.use_set_environment_files && var.use_eric_reverse_proxy ? [{
    "value" : "${local.environment_file_arn_prefix}/generated-${var.eric_environment_filename}",
    "type" : "s3"
  }] : []

  # The eric container definition contains config for the eric service to sit in front of the ecs service app and forward traffic on
  eric_container_definition = <<DEFINITION
        {
          "environment": ${jsonencode(local.updated_eric_environment)},
          "environmentFiles": ${jsonencode(local.eric_environment_file_array)},
          "name": "eric",
          "image": "${var.docker_registry}/eric:${var.eric_version}",
          "cpu": ${var.eric_cpus},
          "memory": ${var.eric_memory},
          "portMappings": [{
              "containerPort": ${var.eric_port},
              "hostPort": ${local.eric_host_port},
              "protocol": "tcp"
          }],
          "links": ${jsonencode(local.eric_links)},
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-region": "${var.aws_region}",
                    "awslogs-group": "/ecs/${var.name_prefix}/eric/${var.service_name}",
                    "awslogs-stream-prefix": "ecs"
                }
            },
            "secrets": ${jsonencode(var.eric_secrets)},
            "essential": true
        }
    DEFINITION


  # combine eric and task container definitions if using eric otherwise just use the single task container. format as a string
  container_definitions_minus_additional = var.use_eric_reverse_proxy ? tolist([jsondecode(local.eric_container_definition), jsondecode(local.task_container_definition)]) : tolist([jsondecode(local.task_container_definition)])
  container_definitions                  = concat(local.container_definitions_minus_additional, [for container in var.additional_containers : jsondecode(container)])


  # Cloudwatch alarm SNS topics - if enabled, either just the notify topic, or both the notify and the ooh (out of hours) topic
  cloudwatch_sns_notify_topic = var.cloudwatch_alarms_enabled ? [data.aws_sns_topic.cloudwatch_alarms_notify_topic[0].arn] : []
  cloudwatch_sns_ooh_topic    = var.cloudwatch_alarms_enabled && var.cloudwatch_alert_to_ooh_enabled ? [data.aws_sns_topic.cloudwatch_alarms_ooh_topic[0].arn] : []
  cloudwatch_sns_topics       = concat(local.cloudwatch_sns_notify_topic, local.cloudwatch_sns_ooh_topic)

  target_container = var.target_container == "" ? var.service_name : var.target_container
}
