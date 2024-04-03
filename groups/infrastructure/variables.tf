variable "aws_region" {
  type = string
}
variable "environment" {
  type = string
}
variable "aws_profile" {
  type = string
}
variable "db_username" {
  type = string
}
variable "enable_deletion_protection" {
  type = bool
}
variable "version" {
  type = string
  default = "0.1.0"
}
