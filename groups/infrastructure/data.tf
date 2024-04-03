data "vault_generic_secret" "secrets" {
  path = "applications/${var.aws_profile}/${var.environment}/${local.stack_name}-stack"
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnets" "monitoring" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = [local.monitoring_subnets_name_pattern]
  }
}

data "aws_ec2_managed_prefix_list" "admin" {
  name = local.admin_prefix_list_name
}

data "aws_ec2_managed_prefix_list" "shared_services_management" {
  name = local.shared_services_management_prefix_list_name
}

# retrieve all secrets for this stack using the stack path
data "aws_ssm_parameters_by_path" "secrets" {
  path = "/${local.name_prefix}"
}
# create a list of secrets names to retrieve them in a nicer format and lookup each secret by name
data "aws_ssm_parameter" "secret" {
  for_each = toset(data.aws_ssm_parameters_by_path.secrets.names)
  name     = each.key
}

data "aws_acm_certificate" "companies_house" {
  domain = "*.${local.companies_house_domain}"
}
