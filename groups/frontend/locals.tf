locals {

  stack_name                       = "dependency-track"
  name_prefix                      = "${local.stack_name}-${var.environment}"
  service_name                     = "dep-track-ui"
  rand_stack_name                  = "rand"
  container_port                   = "8080"
  docker_repo                      = "docker.io"
  client_lb_listener_rule_priority = 7
  healthcheck_interval             = 300
  healthcheck_path                 = "/"
  healthcheck_matcher              = "200-299"
  application_subnet_ids           = data.aws_subnets.application.ids

  stack_secrets = jsondecode(data.vault_generic_secret.secrets.data_json)
  kms_alias     = "alias/${var.aws_profile}/environment-services-kms"

  vpc_name                     = local.stack_secrets["vpc_name"]
  private_subnets_name_pattern = local.stack_secrets["private_subnet_pattern"]
  dev_hosted_zone_name         = local.stack_secrets["dev_hosted_zone_name"]

  alb_name_parameter_name = "/${local.name_prefix}/alb_name"
  ecs_cluster_name        = "${local.rand_stack_name}-${var.environment}-stack"
  db_instance_endpoint    = data.aws_ssm_parameter.secret["/${local.name_prefix}/db-url"].value

  db_name = data.aws_ssm_parameter.secret["/${local.name_prefix}/db-name"].value

  health_check_grace_period_seconds = 60 * 60 # 1 hour

  # create a map of secret name => secret arn to pass into ecs service module
  # using the trimprefix function to remove the prefixed path from the secret name
  secrets_arn_map = {
    for sec in data.aws_ssm_parameter.secret :
    trimprefix(sec.name, "/${local.name_prefix}/") => sec.arn
  }

  client_task_secrets = []

  client_task_environment = [
    { "name" : "API_BASE_URL", "value" : "https://dependency-track.${local.rand_stack_name}.${local.dev_hosted_zone_name}" }
  ]

  cpu_memory_unit = 1024

  client_requirements = {
    cpu             = 0.5 * local.cpu_memory_unit
    memory          = 1 * local.cpu_memory_unit
    docker_registry = "dependencytrack/frontend"
  }
  client_lb_listener_paths = ["/*", "/"]
}
