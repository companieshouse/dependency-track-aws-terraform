variable "aws_region" {
  type = string
}
variable "environment" {
  type = string
}
variable "aws_profile" {
  type = string
}
variable "desired_task_count" {
  type = number
}

variable "applications_developer_version" {
  type = string
}
variable "docker_registry" {
  type = string
}
variable "max_task_count" {
  type = number
}
variable "service_autoscale_enabled" {
  type = string
}
variable "service_autoscale_target_value_cpu" {
  type = number
}
variable "service_scaledown_schedule" {
  type = string
}
variable "service_scaleup_schedule" {
  type = string
}
variable "use_fargate" {
  type = bool
}
