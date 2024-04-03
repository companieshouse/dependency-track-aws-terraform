/*
* Creates a KMS key to use when encrypting dependency track resources
*/
module "kms" {
  source = "git@github.com:companieshouse/terraform-modules//aws/kms?ref=1.0.254"
  kms_key_alias           = local.kms_key_alias
  description             = "Encryption Key for ${var.environment} ${local.stack_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = false
  is_enabled              = true

  tags = {
    Environment = var.environment
    StackName = local.stack_name
    Terraform = true
  }
}
