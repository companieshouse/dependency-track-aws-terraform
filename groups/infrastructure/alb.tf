/*
* Creates an Application Load Balancer which can serve requests from Companies House
* IP Ranges (using the prefix lists)
*/
module "alb" {
  source = "git@github.com:companieshouse/terraform-modules//aws/application_load_balancer?ref=1.0.205"

  environment                = var.environment
  service                    = local.service_name
  ssl_certificate_arn        = data.aws_acm_certificate.companies_house.arn
  subnet_ids                 = data.aws_subnets.monitoring.ids
  vpc_id                     = data.aws_vpc.vpc.id
  internal                   = false
  enable_deletion_protection = false

  create_security_group = true

  ingress_prefix_list_ids = local.asg_ingress_prefix_list
  ingress_cidrs           = nonsensitive(split(",", local.additional_ip_ranges))
  redirect_http_to_https  = true
  service_configuration = {
    default = {
      listener_config = {
        default_action_type = "fixed-response"
        port                = 443
        fixed_response = {
          message_body = "unauthorized"
          status_code  = 401
        }
      }
    }
  }
}
