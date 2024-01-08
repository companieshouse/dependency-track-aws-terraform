resource "aws_ssm_parameter" "dependency_track_domain" {
  name   = "/${local.name_prefix}/domain"
  type   = "SecureString"
  value  = local.dependency_track_host_name
  key_id = data.aws_kms_key.kms_key.id
}

resource "aws_ssm_parameter" "rand_alb_name" {
  name   = "/${local.name_prefix}/alb_name"
  type   = "SecureString"
  value  = module.alb.application_load_balancer_name
  key_id = data.aws_kms_key.kms_key.id
}

resource "aws_ssm_parameter" "rand_alb_sg" {
  name   = "/${local.name_prefix}/alb_security_group_id"
  type   = "SecureString"
  value  = module.alb.security_group_id
  key_id = data.aws_kms_key.kms_key.id
}

resource "aws_ssm_parameter" "username" {
  name   = "/${local.name_prefix}/db-user"
  value  = var.db_username
  type   = "SecureString"
  key_id = data.aws_kms_key.kms_key.id
}

resource "aws_ssm_parameter" "password" {
  name   = "/${local.name_prefix}/db-password"
  value  = local.db_password
  type   = "SecureString"
  key_id = data.aws_kms_key.kms_key.id
}

resource "aws_ssm_parameter" "name" {
  name   = "/${local.name_prefix}/db-name"
  value  = local.db_name
  type   = "SecureString"
  key_id = data.aws_kms_key.kms_key.id
}

resource "aws_ssm_parameter" "url" {
  name   = "/${local.name_prefix}/db-url"
  value  = module.db.db_instance_endpoint
  type   = "SecureString"
  key_id = data.aws_kms_key.kms_key.id
}
