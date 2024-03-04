/*
* Provisions an ECS Service running the Dependency Track front end.
*/

module "client-ecs-service" {
  source = "../modules/ecs-service"

  # Environmental configuration
  environment             = var.environment
  aws_region              = var.aws_region
  aws_profile             = var.aws_profile
  vpc_id                  = data.aws_vpc.vpc.id
  ecs_cluster_id          = data.aws_ecs_cluster.rand.id
  ecs_cluster_name        = data.aws_ecs_cluster.rand.cluster_name
  task_execution_role_arn = data.aws_iam_role.ecs-task-execution-role.arn

  # Load balancer configuration
  lb_listener_arn           = data.aws_lb_listener.dependency-track-lb-listener.arn
  lb_listener_rule_priority = local.client_lb_listener_rule_priority
  lb_listener_paths         = local.client_lb_listener_paths
  healthcheck_path          = local.healthcheck_path
  healthcheck_matcher       = local.healthcheck_matcher

  # ECS Task container health check
  use_task_container_healthcheck = false

  # Docker container details
  docker_registry   = var.docker_registry
  docker_repo       = local.client_requirements.docker_registry
  container_version = var.applications_developer_version
  container_port    = local.container_port

  # Service configuration
  service_name = "dep-track-web"
  name_prefix  = "dep-track-web"

  # Service performance and scaling configs
  desired_task_count                 = var.desired_task_count
  max_task_count                     = var.max_task_count
  required_cpus                      = local.client_requirements.cpu
  required_memory                    = local.client_requirements.memory
  use_fargate                        = var.use_fargate
  fargate_subnets                    = local.application_subnet_ids
  service_autoscale_enabled          = var.service_autoscale_enabled
  service_autoscale_target_value_cpu = var.service_autoscale_target_value_cpu
  service_scaledown_schedule         = var.service_scaledown_schedule
  service_scaleup_schedule           = var.service_scaleup_schedule

  # Service environment variable and secret configs
  task_environment      = local.client_task_environment
  task_secrets          = local.client_task_secrets
  wait_for_steady_state = "false"
}
