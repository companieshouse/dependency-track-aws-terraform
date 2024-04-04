/*
* Adds parameter containing URL of the server to parameter store.
*/

resource "aws_ssm_parameter" "dependency_track_api_url" {
  name   = "/${local.name_prefix}/api-url"
  value  = "https://dependency-track.${local.companies_house_domain}/api"
  type   = "SecureString"
  key_id = data.aws_kms_key.kms_key.id
}
