/*
* Provisions an ECS Service running the Dependency Track server.
*/

module "server-ecs-service" {
  source = "git@github.com:companieshouse/terraform-modules//aws/ecs/ecs-service?ref=bugfix/fix-list-issue"

  # Environmental configuration
  environment             = var.environment
  aws_region              = var.aws_region
  aws_profile             = var.aws_profile
  vpc_id                  = data.aws_vpc.vpc.id
  ecs_cluster_id          = data.aws_ecs_cluster.rand.id
  ecs_cluster_name        = data.aws_ecs_cluster.rand.cluster_name
  task_execution_role_arn = data.aws_iam_role.ecs-task-execution-role.arn

  # Load balancer configuration
  lb_listener_arn                   = data.aws_lb_listener.dependency-track-lb-listener.arn
  lb_listener_rule_priority         = local.server_lb_listener_rule_priority
  lb_listener_paths                 = local.server_lb_listener_paths
  healthcheck_path                  = local.healthcheck_path
  healthcheck_interval              = local.healthcheck_interval
  healthcheck_matcher               = local.healthcheck_matcher
  health_check_grace_period_seconds = local.health_check_grace_period_seconds
  # ECS Task container health check
  use_task_container_healthcheck = false

  # Docker container details
  docker_registry   = var.docker_registry
  docker_repo       = local.server_requirements.docker_registry
  container_version = var.applications_developer_version
  container_port    = local.container_port

  # Service configuration
  service_name = local.service_name
  name_prefix  = local.service_name

  # Service performance and scaling configs
  desired_task_count = var.desired_task_count
  max_task_count     = var.max_task_count
  required_cpus      = local.server_requirements.cpu
  required_memory    = local.server_requirements.memory

  total_service_cpu    = local.task_definition_requirements.cpu
  total_service_memory = local.task_definition_requirements.memory

  use_fargate                        = var.use_fargate
  fargate_subnets                    = local.application_subnet_ids
  service_autoscale_enabled          = var.service_autoscale_enabled
  service_autoscale_target_value_cpu = var.service_autoscale_target_value_cpu
  service_scaledown_schedule         = var.service_scaledown_schedule
  service_scaleup_schedule           = var.service_scaleup_schedule

  # Service environment variable and secret configs
  task_environment = local.server_task_environment
  task_secrets     = local.server_task_secrets

  # Volume/mount configuration
  volumes = {
    efs : {
      efs_volume_configuration : {
        file_system_id : aws_efs_file_system.server_efs.id
        transit_encryption : "ENABLED"
        transit_encryption_port : 2999
        authorization_config : {
          access_point_id : aws_efs_access_point.server_efs.id
        }
      }
    }
  }

  mount_points = [{
    "sourceVolume" : "efs",
    "containerPath" : "/data/",
    "readOnly" : false
  }]

  additional_sidecar_containers = [{
    image: "${data.aws_ecr_repository.proxy_sidecar.repository_url}:${var.sidecar_version}",
    name: local.sidecar_container_name,
    memory: local.sidecar_requirements.memory,
    cpu: local.sidecar_requirements.cpu,
    port_mappings: [{
      container_port: var.sidecar_port,
      host_port: var.sidecar_port
    }],
    essential: true,
    depends_on: [
      {
        container_name: local.service_name
      }
    ]
  }]

  target_container_name = local.sidecar_container_name
  target_container_port = var.sidecar_port
  wait_for_steady_state = "false"
}
