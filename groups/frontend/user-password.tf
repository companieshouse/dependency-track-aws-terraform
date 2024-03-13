/*
* Generates a random password for the administrator user and stores in parameter store
*/

resource "random_password" "admin_password" {
  length           = 13
  special          = true
  override_special = "!?@$%&*"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_ssm_parameter" "admin_password" {
  name   = "/${local.name_prefix}/admin/password"
  value  = random_password.admin_password.result
  type   = "SecureString"
  key_id = data.aws_kms_key.kms_key.id
}
