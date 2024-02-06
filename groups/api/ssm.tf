resource "aws_ssm_parameter" "dependency_track_api_url" {
  name   = "/${local.name_prefix}/api-url"
  value  = "https://dependency-track.rand.${local.dev_hosted_zone_name}/api"
  type   = "SecureString"
  key_id = data.aws_kms_key.kms_key.id
}
