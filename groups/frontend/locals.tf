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
  monitoring_subnet_ids            = data.aws_subnets.monitoring.ids

  stack_secrets       = jsondecode(data.vault_generic_secret.stack_secrets.data_json)
  application_secrets = jsondecode(data.vault_generic_secret.application_secrets.data_json)

  vpc_name                        = local.stack_secrets["vpc_name"]
  monitoring_subnets_name_pattern = local.stack_secrets["monitoring_subnet_pattern"]
  companies_house_domain          = local.stack_secrets["companies_house_domain"]

  alb_name_parameter_name = "/${local.name_prefix}/alb-name"
  ecs_cluster_name        = data.aws_ssm_parameter.stack_cluster_name.value

  health_check_grace_period_seconds = 60 * 60 # 1 hour

  # create a map of secret name => secret arn to pass into ecs service module
  # using the trimprefix function to remove the prefixed path from the secret name
  secrets_arn_map = {
    for sec in data.aws_ssm_parameter.secret :
    trimprefix(sec.name, "/${local.name_prefix}/") => sec.arn
  }

  application_secrets_arn_map = {
    for sec in module.server-ecs-secrets.secrets :
    trimprefix(sec.name, "/${local.name_prefix}/") => sec.arn
  }

  client_task_secrets = [
    { "name" : "OIDC_CLIENT_ID", "valueFrom" : local.application_secrets_arn_map["oidc-client-id"] },
    { "name" : "OIDC_ISSUER", "valueFrom" : local.application_secrets_arn_map["oidc-issuer"] },
  ]

  client_task_environment = [
    { "name" : "API_BASE_URL", "value" : "https://dependency-track.${local.companies_house_domain}" }
  ]

  cpu_memory_unit = 1024

  client_requirements = {
    cpu             = 2 * local.cpu_memory_unit
    memory          = 4 * local.cpu_memory_unit
    docker_registry = "dependencytrack-frontend"
  }
  client_lb_listener_paths = ["/*", "/"]
  default_tags = {
    Environment = var.environment
    ServiceName = local.service_name
    StackName   = local.stack_name
    Terraform   = true
    Version     = var.dependency_track_aws_terraform_version
    Repository  = "companieshouse/dependency-track-aws-terraform"
    Group       = "frontend"
  }
}
