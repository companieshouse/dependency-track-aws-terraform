# Define all hardcoded local variable and local variables looked up from data resources
locals {
  stack_name             = "dependency-track" # this must match the stack name the service deploys into
  name_prefix            = "${local.stack_name}-${var.environment}"
  service_name           = "dependency-track"
  rand_stack_name        = "rand"
  kms_key_alias          = "alias/${var.aws_profile}/${var.environment}/${local.stack_name}"

  stack_secrets = jsondecode(data.vault_generic_secret.secrets.data_json)

  vpc_name                                    = local.stack_secrets["vpc_name"]
  monitoring_subnets_name_pattern             = local.stack_secrets["monitoring_subnet_pattern"]
  companies_house_domain                      = local.stack_secrets["companies_house_domain"]
  admin_prefix_list_name                      = local.stack_secrets["admin_prefix_list_name"]
  shared_services_management_prefix_list_name = local.stack_secrets["shared_services_management_prefix_list_name"]
  additional_ip_ranges                        = local.stack_secrets["additional_ip_ranges"]

  asg_ingress_prefix_list = [data.aws_ec2_managed_prefix_list.admin.id, data.aws_ec2_managed_prefix_list.shared_services_management.id]

  alb_name_parameter_name = "/${local.rand_stack_name}-${var.environment}/alb_name"
  ecs_cluster_name        = "${local.rand_stack_name}-${var.environment}-stack"
  db_password             = random_password.db_password.result
  db_name                 = "dtrack"

  default_tags = {
    Environment = var.environment
    StackName   = local.stack_name
    Terraform   = true
    Version     = var.dependency_track_aws_terraform_version
    Repository  = "companieshouse/dependency-track-aws-terraform"
    Group       = "infrastructure"
  }
}
