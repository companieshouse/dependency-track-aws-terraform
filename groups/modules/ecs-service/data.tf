data "aws_caller_identity" "current" {}

// --- s3 bucket for shared services config ---
data "vault_generic_secret" "shared_s3" {
  path = "aws-accounts/shared-services/s3"
}

data "aws_lb_listener" "lb_listener" {
  arn = var.lb_listener_arn
}

data "aws_lb" "lb" {
  arn = data.aws_lb_listener.lb_listener.load_balancer_arn
}

data "aws_sns_topic" "cloudwatch_alarms_notify_topic" {
  count = var.cloudwatch_alarms_enabled ? 1 : 0
  name  = length(var.cloudwatch_alert_notify_topic) > 0 ? var.cloudwatch_alert_notify_topic : "${var.name_prefix}-cloudwatch-alarms-notify-topic"
}

data "aws_sns_topic" "cloudwatch_alarms_ooh_topic" {
  count = var.cloudwatch_alarms_enabled && var.cloudwatch_alert_to_ooh_enabled ? 1 : 0
  name  = length(var.cloudwatch_alert_ooh_topic) > 0 ? var.cloudwatch_alert_ooh_topic : "${var.name_prefix}-cloudwatch-alarms-ooh-topic"
}
