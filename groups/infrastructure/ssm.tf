/*
* Creates the SSM Parameters with important details about Dependency Track
* to be consumed by other groups.
*/


resource "aws_ssm_parameter" "rand_alb_name" {
  name   = "/${local.name_prefix}/alb-name"
  type   = "SecureString"
  value  = module.alb.application_load_balancer_name
  key_id = aws_kms_key.key.id
}

resource "aws_ssm_parameter" "rand_alb_sg" {
  name   = "/${local.name_prefix}/alb-security-group-id"
  type   = "SecureString"
  value  = module.alb.security_group_id
  key_id = aws_kms_key.key.id
}

resource "aws_ssm_parameter" "username" {
  name   = "/${local.name_prefix}/db-user"
  value  = var.db_username
  type   = "SecureString"
  key_id = aws_kms_key.key.id
}

resource "aws_ssm_parameter" "password" {
  name   = "/${local.name_prefix}/db-password"
  value  = local.db_password
  type   = "SecureString"
  key_id = aws_kms_key.key.id
}

resource "aws_ssm_parameter" "name" {
  name   = "/${local.name_prefix}/db-name"
  value  = local.db_name
  type   = "SecureString"
  key_id = aws_kms_key.key.id
}

resource "aws_ssm_parameter" "url" {
  name   = "/${local.name_prefix}/db-url"
  value  = module.db.db_instance_endpoint
  type   = "SecureString"
  key_id = aws_kms_key.key.id
}

resource "aws_ssm_parameter" "kms_key_alias" {
  name   = "/${local.name_prefix}/kms-key-alias"
  value  = "${local.kms_key_alias}"
  type   = "SecureString"
  key_id = aws_kms_key.key.id
}

resource "aws_ssm_parameter" "cluster_name" {
  name   = "/${local.name_prefix}/stack-cluster-name"
  value  = aws_ecs_cluster.cluster.name
  type   = "SecureString"
  key_id = aws_kms_key.key.id
}

resource "aws_ssm_parameter" "cluster_id" {
  name   = "/${local.name_prefix}/stack-cluster-id"
  value  = aws_ecs_cluster.cluster.id
  type   = "SecureString"
  key_id = aws_kms_key.key.id
}
