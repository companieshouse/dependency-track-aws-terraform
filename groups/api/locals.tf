locals {
  stack_name                       = "dependency-track"
  name_prefix                      = "${local.stack_name}-${var.environment}"
  service_name                     = "dep-track-api"
  container_port                   = "8080"
  docker_repo                      = "docker.io"
  server_lb_listener_rule_priority = 6
  healthcheck_interval             = 300
  healthcheck_path                 = "/health"
  healthcheck_matcher              = "200-299"
  monitoring_subnet_ids            = data.aws_subnets.monitoring.ids

  stack_secrets       = jsondecode(data.vault_generic_secret.stack_secrets.data_json)
  application_secrets = jsondecode(data.vault_generic_secret.stack_secrets.data_json)

  vpc_name                        = local.stack_secrets["vpc_name"]
  monitoring_subnets_name_pattern = local.stack_secrets["monitoring_subnet_pattern"]
  companies_house_domain          = local.stack_secrets["companies_house_domain"]

  alb_name_parameter_name = "/${local.name_prefix}/alb-name"
  ecs_cluster_name        = data.aws_ssm_parameter.stack_cluster_name.value
  db_instance_endpoint    = data.aws_ssm_parameter.secret["/${local.name_prefix}/db-url"].value

  db_name = data.aws_ssm_parameter.secret["/${local.name_prefix}/db-name"].value

  health_check_grace_period_seconds = 60 * 60 # 1 hour

  parameter_store_secrets = {
    "oidc-client-id": local.application_secrets["oidc-client-id"],
    "oidc-issuer": local.application_secrets["oidc-issuer"],
    "oidc-username-claim": local.application_secrets["oidc-username-claim"],
    "oidc-teams-claim": local.application_secrets["oidc-teams-claim"],
  }

  # create a map of secret name => secret arn to pass into ecs service module
  # using the trimprefix function to remove the prefixed path from the secret name
  secrets_arn_map = {
    for sec in data.aws_ssm_parameter.secret :
    trimprefix(sec.name, "/${local.name_prefix}/") => sec.arn
  }

  service_secrets_arn_map = {
    for sec in module.server-ecs-secrets.secrets :
    trimprefix(sec.name, "/${local.service_name}-${var.environment}/") => sec.arn
  }

  server_task_secrets = [
    { "name" : "ALPINE_DATABASE_USERNAME", "valueFrom" : local.secrets_arn_map["db-user"] },
    { "name" : "ALPINE_DATABASE_PASSWORD", "valueFrom" : local.secrets_arn_map["db-password"] },
    { "name" : "ALPINE_OIDC_CLIENT_ID", "valueFrom" : local.service_secrets_arn_map["oidc-client-id"] },
    { "name" : "ALPINE_OIDC_ISSUER", "valueFrom" : local.service_secrets_arn_map["oidc-issuer"] },
    { "name" : "ALPINE_OIDC_USERNAME_CLAIM", "valueFrom" : local.service_secrets_arn_map["oidc-username-claim"] },
    { "name" : "ALPINE_OIDC_TEAMS_CLAIM", "valueFrom" : local.service_secrets_arn_map["oidc-teams-claim"] },
  ]
  # Other Database env vars:

  # ALPINE_DATABASE_POOL_ENABLED
  # ALPINE_DATABASE_POOL_MAX_SIZE
  # ALPINE_DATABASE_POOL_MIN_IDLE
  # ALPINE_DATABASE_POOL_IDLE_TIMEOUT
  # ALPINE_DATABASE_POOL_MAX_LIFETIME

  server_task_environment = [
    { "name" : "ALPINE_DATABASE_MODE", "value" : "external" },
    { "name" : "ALPINE_DATABASE_DRIVER", "value" : "org.postgresql.Driver" },
    { "name" : "ALPINE_DATABASE_URL", "value" : "jdbc:postgresql://${local.db_instance_endpoint}/${local.db_name}" },
    { "name" : "ALPINE_DATABASE_POOL_ENABLED", "value" : "true" },
    { "name" : "ALPINE_DATABASE_POOL_MAX_SIZE", "value" : "30" },
    { "name" : "ALPINE_METRICS_ENABLED", "value" : "true" },
    { "name" : "ALPINE_WORKER_THREADS", "value" : "7" },
    { "name" : "ALPINE_WORKER_THREAD_MULTIPLIER", "value" : "3" },
    { "name" : "EXTRA_JAVA_OPTIONS", "value" : "-Xms8g -Xmx16g -XX:ActiveProcessorCount=8" },
    { "name" : "ALPINE_OIDC_ENABLED", "value" : "true" },
    { "name" : "ALPINE_OIDC_USER_PROVISIONING", "value" : "true" },
    { "name" : "ALPINE_OIDC_TEAM_SYNCHRONIZATION", "value" : "true" }
  ]

  cpu_memory_unit = 1024

  server_requirements = {
    cpu             = 4 * local.cpu_memory_unit
    memory          = 16 * local.cpu_memory_unit
    docker_registry = "dependencytrack-apiserver"
  }
  sidecar_requirements = {
    cpu    = 0.5 * local.cpu_memory_unit
    memory = local.cpu_memory_unit
  }
  task_definition_requirements = {
    cpu    = 8 * local.cpu_memory_unit
    memory = 20 * local.cpu_memory_unit
  }
  server_lb_listener_paths = ["/api/*", "/api"]

  sidecar_environment    = []
  sidecar_secrets        = []
  sidecar_container_name = "proxy-sidecar"
  sidecar_image          = "${var.docker_registry}/dependencytrack-proxy-sidecar:${var.dependency_track_aws_terraform_version}"

  default_tags = {
    Environment = var.environment
    ServiceName = local.service_name
    StackName   = local.stack_name
    Terraform   = true
    Version     = var.dependency_track_aws_terraform_version
    Repository  = "companieshouse/dependency-track-aws-terraform"
    Group       = "api"
  }
}
