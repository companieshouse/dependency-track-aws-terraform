/*
* Exposes the application secrets held in vault as SSM parameters
*/
module "frontend-ecs-secrets" {
  source = "git@github.com:companieshouse/terraform-modules//aws/ecs/secrets?ref=1.0.254"

  environment = var.environment
  name_prefix = "${local.service_name}-${var.environment}"
  secrets     = local.application_secrets
  kms_key_id  = data.aws_kms_key.kms_key.id
}
