/*
* Creates the SSM Parameters with important details about Dependency Track
* to be consumed by other groups.
*/


resource "aws_ssm_parameter" "rand_alb_name" {
  name   = "/${local.name_prefix}/alb_name"
  type   = "SecureString"
  value  = module.alb.application_load_balancer_name
  key_id = module.kms.key_id
}

resource "aws_ssm_parameter" "rand_alb_sg" {
  name   = "/${local.name_prefix}/alb_security_group_id"
  type   = "SecureString"
  value  = module.alb.security_group_id
  key_id = module.kms.key_id
}

resource "aws_ssm_parameter" "username" {
  name   = "/${local.name_prefix}/db-user"
  value  = var.db_username
  type   = "SecureString"
  key_id = module.kms.key_id
}

resource "aws_ssm_parameter" "password" {
  name   = "/${local.name_prefix}/db-password"
  value  = local.db_password
  type   = "SecureString"
  key_id = module.kms.key_id
}

resource "aws_ssm_parameter" "name" {
  name   = "/${local.name_prefix}/db-name"
  value  = local.db_name
  type   = "SecureString"
  key_id = module.kms.key_id
}

resource "aws_ssm_parameter" "url" {
  name   = "/${local.name_prefix}/db-url"
  value  = module.db.db_instance_endpoint
  type   = "SecureString"
  key_id = module.kms.key_id
}

resource "aws_ssm_parameter" "kms_key_alias" {
  name   = "/${local.name_prefix}/kms-key-alias"
  value  = local.kms_key_alias
  type   = "SecureString"
  key_id = module.kms.key_id
}
