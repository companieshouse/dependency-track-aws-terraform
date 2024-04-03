/*
* Creates a KMS key to use when encrypting dependency track resources
*/
resource "aws_kms_key" "key" {
  description             = "Encryption Key for ${var.environment} ${local.stack_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = false
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"
  policy                  = data.aws_iam_policy_document.kms_key_policy.json
  tags = {
    Environment = var.environment
    StackName = local.stack_name
    Terraform = true
  }
}

resource "aws_kms_alias" "key_alias" {
  target_key_id = aws_kms_key.key.id
  name          = local.kms_key_alias
}
