# Define all hardcoded local variable and local variables looked up from data resources
locals {
  stack_name             = "dependency-track" # this must match the stack name the service deploys into
  name_prefix            = "${local.stack_name}-${var.environment}"
  service_name           = "dependency-track"
  rand_stack_name        = "rand"
  application_subnet_ids = data.aws_subnets.application.ids

  stack_secrets = jsondecode(data.vault_generic_secret.secrets.data_json)

  vpc_name                     = local.stack_secrets["vpc_name"]
  public_subnets_name_pattern  = local.stack_secrets["public_subnet_pattern"]
  private_subnets_name_pattern = local.stack_secrets["private_subnet_pattern"]
  dev_hosted_zone_name         = local.stack_secrets["dev_hosted_zone_name"]
  admin_prefix_list_name       = local.stack_secrets["admin_prefix_list_name"]

  asg_ingress_prefix_list = [data.aws_ec2_managed_prefix_list.admin.id]

  dependency_track_host_name = "dependency-track.rand.${local.dev_hosted_zone_name}"

  alb_name_parameter_name = "/${local.rand_stack_name}-${var.environment}/alb_name"
  ecs_cluster_name        = "${local.rand_stack_name}-${var.environment}-stack"
  db_password             = random_password.db_password.result
  db_name                 = "dtrack"
  kms_alias               = "alias/${var.aws_profile}/environment-services-kms"
}
