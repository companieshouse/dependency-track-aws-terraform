locals {
  stack_name                       = "dependency-track"
  name_prefix                      = "${local.stack_name}-${var.environment}"
  service_name                     = "dep-track-api"
  rand_stack_name                  = "rand"
  container_port                   = "8080" # default node port required here until prod docker container is built allowing port change via env var
  docker_repo                      = "docker.io"
  server_lb_listener_rule_priority = 6
  healthcheck_interval             = 300
  healthcheck_path                 = "/health"
  healthcheck_matcher              = "200-299" # no explicit healthcheck in this service yet, change this when added!
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

  server_task_secrets = [
    { "name" : "ALPINE_DATABASE_USERNAME", "valueFrom" : local.secrets_arn_map["db-user"] },
    { "name" : "ALPINE_DATABASE_PASSWORD", "valueFrom" : local.secrets_arn_map["db-password"] },
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
    { "name" : "EXTRA_JAVA_OPTIONS", "value" : "-Xms8g -Xmx16g -XX:ActiveProcessorCount=8" }
  ]

  cpu_memory_unit = 1024

  server_requirements = {
    # cpu             = 2 * local.cpu_memory_unit
    cpu = 4 * local.cpu_memory_unit
    # memory          = 5 * local.cpu_memory_unit
    memory          = 16 * local.cpu_memory_unit
    docker_registry = "dependencytrack/apiserver"
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

  sidecar_environment = []
  sidecar_secrets     = []
  sidecar_container   = <<EOF
{
  "name": "proxy-sidecar",
  "image": "${data.aws_ecr_repository.proxy_sidecar.repository_url}:${var.sidecar_version}",
  "cpu": ${local.sidecar_requirements.cpu},
  "memory": ${local.sidecar_requirements.memory},
  "portMappings": [{
      "containerPort": ${var.sidecar_port},
      "hostPort": ${var.sidecar_port},
      "protocol": "tcp"
  }],
  "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-create-group": "true",
          "awslogs-region": "${var.aws_region}",
          "awslogs-group": "/ecs/${local.name_prefix}/proxy-sidecar/${local.service_name}",
          "awslogs-stream-prefix": "ecs"
      }
  },
  "dependsOn": [{
    "containerName": "${local.service_name}",
    "condition": "START"
  }],
  "essential": true
}}
EOF
}
