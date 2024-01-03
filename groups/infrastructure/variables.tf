variable "aws_region" {
  type = string
}
variable "environment" {
  type = string
}
variable "aws_profile" {
  type = string
}
variable "docker_registry" {
  type = string
}
variable "applications_developer_version" {
  type = string
}
variable "desired_task_count" {
  type = number
}
variable "max_task_count" {
  type = number
}
variable "required_cpus" {
  type = number
}
variable "required_memory" {
  type = number
}
variable "use_fargate" {
  type = bool
}
variable "service_autoscale_enabled" {
  type = bool
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
variable "db_username" {
  type = string
}

variable "enable_deletion_protection" {
  type = bool
}
