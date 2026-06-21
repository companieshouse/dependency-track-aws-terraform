locals {
  # test values hardcoded here
  stack_name  = "stackname"
  environment = "environment"
  name_prefix = "${local.stack_name}-${local.environment}"
  aws_region  = "eu-west-2"
  aws_profile = "development-eu-west-2"

  container_port            = 8080
  lb_listener_rule_priority = 100
  lb_listener_paths         = ["/*"]

  task_secrets = []
  task_environment = [
    { "name" : "PORT", "value" : "${local.container_port}" },
    { "name" : "LOGLEVEL", "value" : "debug" }
  ]

  service_name            = "servicename"
  docker_repo             = "dockerrepo"
  ecs_cluster_id          = "ecsclusterid"
  task_execution_role_arn = "arn:aws:iam::000000000000:role/taskexecutionrolearn"
  lb_listener_arn         = "arn:aws:elasticloadbalancing:eu-west-2:000000000000:listener/app/lblistenerarn/0000000000000000/0000000000000000"
  docker_registry         = "dockerregistry"
  container_version       = "containerversion"
  fargate_subnets         = ["12345"]

  eric_secrets = []
  eric_environment = [
    { "name" : "LOGLEVEL", "value" : "debug" },
    { "name" : "MODE", "value" : "api" }
  ]

  additional_containers = [
    {
      name : "proxy-sidecar",
      image : "docker.io/nginx:1.25.4",
      cpu : 192,
      memory : 256,
      portMappings : [{
        containerPort : 8080,
        hostPort : 8080,
        protocol : "tcp"
      }],
      dependsOn : [{
        containerName : "${local.service_name}",
        condition : "START"
      }],
      essential : true
    }
  ]

  additional_containers_only_required = [
    {
      name : "proxy-sidecar",
      image : "docker.io/nginx:1.25.4",
      cpu : 192,
      memory : 256
    }
  ]
}

provider "aws" {
  region = local.aws_region
}

terraform {
  backend "s3" {
  }
}

# Get default VPC and subnets to keep test simple rather than using netowkrs remote state
data "aws_vpc" "default" {
  default = true
}

# no eric reverse proxy
module "ecs-service" {
  source = "../" # up to root of repo

  # Environmental configuration
  environment             = local.environment
  aws_region              = local.aws_region
  aws_profile             = local.aws_profile
  vpc_id                  = data.aws_vpc.default.id
  ecs_cluster_id          = local.ecs_cluster_id
  task_execution_role_arn = local.task_execution_role_arn

  # Load balancer configuration
  lb_listener_arn           = local.lb_listener_arn
  lb_listener_rule_priority = local.lb_listener_rule_priority
  lb_listener_paths         = local.lb_listener_paths

  # Docker container details
  docker_registry   = local.docker_registry
  docker_repo       = local.docker_repo
  container_version = local.container_version
  container_port    = local.container_port

  # Service configuration
  service_name = local.service_name
  name_prefix  = local.name_prefix

  # Service environment variable and secret configs
  task_environment = local.task_environment
  task_secrets     = local.task_secrets

  use_fargate     = true
  fargate_subnets = local.fargate_subnets
}

# test eric reverse proxy
module "ecs-service-eric" {
  source = "../" # up to root of repo

  # Environmental configuration
  environment             = local.environment
  aws_region              = local.aws_region
  aws_profile             = local.aws_profile
  vpc_id                  = data.aws_vpc.default.id
  ecs_cluster_id          = local.ecs_cluster_id
  task_execution_role_arn = local.task_execution_role_arn

  # Load balancer configuration
  lb_listener_arn           = local.lb_listener_arn
  lb_listener_rule_priority = local.lb_listener_rule_priority
  lb_listener_paths         = local.lb_listener_paths

  # Docker container details
  docker_registry   = local.docker_registry
  docker_repo       = local.docker_repo
  container_version = local.container_version
  container_port    = local.container_port

  # Service configuration
  service_name = "${local.service_name}-eric"
  name_prefix  = local.name_prefix

  # Service environment variable and secret configs
  task_environment = local.task_environment
  task_secrets     = local.task_secrets

  use_fargate     = true
  fargate_subnets = local.fargate_subnets

  use_eric_reverse_proxy  = true
  eric_port               = 10000
  eric_version            = "eric_version"
  eric_cpus               = 192
  eric_memory             = 256
  eric_environment        = local.eric_environment
  eric_secrets            = local.eric_secrets
  eric_extra_bypass_paths = "/bypass-path/test"
}

# Test additional containers
module "ecs-service-multiple-containers" {
  source = "../" # up to root of repo

  # Environmental configuration
  environment             = local.environment
  aws_region              = local.aws_region
  aws_profile             = local.aws_profile
  vpc_id                  = data.aws_vpc.default.id
  ecs_cluster_id          = local.ecs_cluster_id
  task_execution_role_arn = local.task_execution_role_arn

  # Load balancer configuration
  lb_listener_arn           = local.lb_listener_arn
  lb_listener_rule_priority = local.lb_listener_rule_priority
  lb_listener_paths         = local.lb_listener_paths

  # Docker container details
  docker_registry   = local.docker_registry
  docker_repo       = local.docker_repo
  container_version = local.container_version
  container_port    = local.container_port

  # Service configuration
  service_name = "${local.service_name}-multiple-containers"
  name_prefix  = local.name_prefix

  # Service environment variable and secret configs
  task_environment = local.task_environment
  task_secrets     = local.task_secrets

  use_fargate     = true
  fargate_subnets = local.fargate_subnets

  additional_sidecar_containers = local.additional_containers
  target_container_name      = "proxy-sidecar"
  target_container_port = "8080"
  total_service_memory        = 256 + 512
  total_service_cpu           = 128 + 192
}

# Test additional containers
module "ecs-service-multiple-containers-minimum-details" {
  source = "../" # up to root of repo

  # Environmental configuration
  environment             = local.environment
  aws_region              = local.aws_region
  aws_profile             = local.aws_profile
  vpc_id                  = data.aws_vpc.default.id
  ecs_cluster_id          = local.ecs_cluster_id
  task_execution_role_arn = local.task_execution_role_arn

  # Load balancer configuration
  lb_listener_arn           = local.lb_listener_arn
  lb_listener_rule_priority = local.lb_listener_rule_priority
  lb_listener_paths         = local.lb_listener_paths

  # Docker container details
  docker_registry   = local.docker_registry
  docker_repo       = local.docker_repo
  container_version = local.container_version
  container_port    = local.container_port

  # Service configuration
  service_name = "${local.service_name}-multiple-containers"
  name_prefix  = local.name_prefix

  # Service environment variable and secret configs
  task_environment = local.task_environment
  task_secrets     = local.task_secrets

  use_fargate     = true
  fargate_subnets = local.fargate_subnets

  additional_sidecar_containers = local.additional_containers_only_required
  target_container_name      = "proxy-sidecar"
  target_container_port = "8080"
  total_service_memory        = 256 + 512
  total_service_cpu           = 128 + 192
}
