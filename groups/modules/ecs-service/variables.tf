# ------------------------------------------------------------------------------
# Environmental configuration
# ------------------------------------------------------------------------------
variable "environment" {
  type        = string
  description = "The environment name, defined in envrionments vars."
}

variable "aws_region" {
  default     = "eu-west-2"
  type        = string
  description = "The AWS region for deployment."
}

variable "aws_profile" {
  type        = string
  description = "The AWS profile to use for deployment."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC in use for the ECS cluster and associated resources e.g. ALBs."
}

variable "ecs_cluster_id" {
  type        = string
  description = "The ID of the ECS cluster the ECS service will be created in."
}

variable "ecs_cluster_name" {
  type = string
  description = "The name of the ecs cluster"
  default = ""
}

variable "task_execution_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use to create and launch the ECS service tasks."
}

variable "additional_containers" {
  type        = list(string)
  description = "List of additional containers to add to task definition"
  default     = []
}

variable "task_role_arn" {
  type        = string
  description = "The ARN of the IAM role used by the ECS tasks while running. If left blank, a task role will not be used."
  default     = ""
}

variable "enable_execute_command" {
  type        = bool
  description = "Whether to enable the use of ECS Exec for the service.  If enabled, a suitable task_role_arn, such as the one created at cluster level, must be supplied."
  default     = false
}

variable "fargate_subnets" {
  type        = list(string)
  description = "The subnets to use when running the service with fargate"
  default     = []
}

variable "fargate_ingress_cidrs" {
  type        = list(string)
  description = "A list of CIDR blocks that will be allowed ingress access to the fargate instances"
  default     = []
}

variable "fargate_ingress_prefix_list_ids" {
  type        = list(string)
  description = "A list of prefix list IDs that will be allowed ingress access to the fargate instances"
  default     = []
}

variable "fargate_ingress_security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs that will be allowed ingress access to the fargate instances"
  default     = []
}

variable "fargate_permit_existing_alb" {
  type        = bool
  description = "Defines whether an already existing ALB is being used and should be permitted access via the fargate security group. If true, a rule will be added permitting ingress from the ALB's security group. Should be defined as false if the ALB doesn't yet exist or if the rule is not desired."
  default     = true
}

variable "use_capacity_provider" {
  type        = bool
  description = "Whether to use a capacity provider instead of setting a launch type for the service"
  default     = false
}

variable "default_tags" {
  description = "A map of default tags to be added to the resources"
  type        = map(any)
  default     = {}
}

# ------------------------------------------------------------------------------
# Docker container details
# ------------------------------------------------------------------------------
variable "docker_registry" {
  type        = string
  description = "The FQDN of the docker registry."
}

variable "docker_repo" {
  type        = string
  description = "The repository to use with in the given docker registry."
}

variable "container_version" {
  type        = string
  description = "The version of the docker container to run."
}

variable "container_port" {
  type        = number
  description = "The port the container exposes. This must match the port used by the service in its environment variables."
}

# ------------------------------------------------------------------------------
# Service configuration
# ------------------------------------------------------------------------------
variable "service_name" {
  type        = string
  description = "The user friendly service name used to name AWS resources."
}

variable "name_prefix" {
  type        = string
  description = "The user friendly name prefix used to name AWS resources."
}

variable "wait_for_steady_state" {
  type        = string
  description = "Optional flag for TF to wait for the service to go into a steady state"
  default     = "true"
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION."
  default     = "TASK_DEFINITION"
}

# ------------------------------------------------------------------------------
# Service performance and scaling configs
# ------------------------------------------------------------------------------
variable "desired_task_count" {
  type        = number
  description = "The desired ECS task count for this service"
  default     = 1
}

variable "max_task_count" {
  type        = number
  description = "The maximum number of tasks for this service."
  default     = 2
}

variable "min_task_count" {
  default     = 1
  type        = number
  description = "The minimum number of tasks for this service."
}

variable "required_cpus" {
  type        = number
  description = "The required cpu resource for this service. 1024 here is 1 vCPU"
  default     = 128
}

variable "required_memory" {
  type        = number
  description = "The required memory for this service"
  default     = 256
}

variable "use_fargate" {
  type        = bool
  description = "If true, sets the required capabilities for all containers in the task definition to use FARGATE, false uses EC2"
  default     = false
}

variable "mount_points" {
  type        = list(any)
  description = "Used to define mount points in the container definition"
  default     = []
}

variable "volumes" {
  description = "Configuration block for volumes that containers in your task may use"
  type        = any
  default     = {}
}

variable "ulimits" {
  description = "Configuration for ulimit values that the containers use"
  type = list(object({
    hardLimit = number
    name      = string
    softLimit = number
  }))
  default = []
}

variable "service_autoscale_enabled" {
  type        = bool
  description = "Whether to enable service autoscaling, including scheduled autoscaling"
  default     = false
}

variable "service_autoscale_target_value_cpu" {
  type        = number
  description = "Target CPU percentage for the ECS Service to autoscale on"
  default     = 100 # 100 disables autoscaling using CPU as a metric
}

variable "service_autoscale_target_value_mem" {
  type        = number
  description = "Target Memory Utilisation percentage for the ECS Service to autoscale on"
  default     = 100 # 100 disables autoscaling using memory as a metric
}

variable "service_autoscale_scale_in_cooldown" {
  type        = number
  description = "Cooldown in seconds for ECS Service scale in"
  default     = 300
}

variable "service_autoscale_scale_out_cooldown" {
  type        = number
  description = "Cooldown in seconds for ECS Service scale out"
  default     = 300
}

variable "service_scaledown_schedule" {
  type        = string
  description = "The schedule to use when scaling down the number of tasks to zero."
  # Typically used to stop all tasks in a service to save resource costs overnight.
  # E.g. a value of '55 19 * * ? *' would be Mon-Sun 7:55pm.  An empty string indicates that no schedule should be created.

  default = ""
}

variable "service_scaleup_schedule" {
  type        = string
  description = "The schedule to use when scaling up the number of tasks to their normal desired level."
  # Typically used to start all tasks in a service after it has been shutdown overnight.
  # E.g. a value of '5 6 * * ? *' would be Mon-Sun 6:05am.  An empty string indicates that no schedule should be created.

  default = ""
}

# ------------------------------------------------------------------------------
# Service environment variable and secret configs
# ------------------------------------------------------------------------------
variable "task_environment" {
  type        = list(any)
  description = "The environment variables required by the service to be included in the task definition"
}

variable "environment_files" {
  type        = list(any)
  default     = []
  description = "The environment files to define variables needed by the ecs service tasks. These file will be ignored when use_set_environment_files is set to true."
}

variable "use_set_environment_files" {
  type        = bool
  default     = false
  description = "Toggle default global and shared  environment files. If this is set to true, the global and shared files for the environment will be used. The app_environment_filename MUST also be defined if this is set to true"
}

variable "app_environment_filename" {
  type        = string
  default     = ""
  description = "s3 env file for application. This value MUST be defined if use_set_environment_files is set to true"
}

variable "task_secrets" {
  type        = list(any)
  description = "The secrets required by the service to be included in the task definition. The values must be Parameter Store Secret ARNs not plaintext."
}

# ------------------------------------------------------------------------------
# Load balancer configuration
# ------------------------------------------------------------------------------
variable "lb_listener_arn" {
  type        = string
  description = "The ARN of the load balancer the ECS service will sit behind."
}

variable "lb_listener_rule_priority" {
  type        = number
  description = "The priority to use when attaching the services listener rules to the load balancer."

  validation {
    condition     = var.lb_listener_rule_priority > 0 && var.lb_listener_rule_priority < 5000
    error_message = "The value of lb_listener_rule_priority must be greater than 0 and less than 5000"
  }
}

variable "lb_listener_paths" {
  type        = list(string)
  description = "The path regex patterns that this service controls. Traffic to the load balancer will only be sent to this ECS service if it matches one of these defined path patterns."

  validation {
    condition     = length(var.lb_listener_paths) <= 50
    error_message = "The lb_listener_paths list must contain 50 or fewer entries."
  }
}
variable "enable_listener" {
  type        = bool
  default     = true
  description = "If true, enable listener will create the listener rules.  If false the listener rules will not be created.  This variable can be defined in the service."
}

variable "use_task_container_healthcheck" {
  type        = bool
  description = "If true, sets the ECS Tasks' container health check"
  default     = false
}

variable "healthcheck_path" {
  type        = string
  description = "The path to use to perform service healthchecks."
  default     = "/healthcheck"
}

variable "healthcheck_matcher" {
  type        = string
  description = "The expected response code to pass service healthchecks."
  default     = "200"
}

variable "healthcheck_healthy_threshold" {
  type        = string
  description = "The number of healthchecks required to become healthy."
  default     = "3"
}

variable "healthcheck_unhealthy_threshold" {
  type        = string
  description = "The number of healthchecks required to become unhealthy."
  default     = "3"
}

variable "healthcheck_interval" {
  type        = string
  description = "The interval between service healthchecks."
  default     = "30"
}

variable "health_check_grace_period_seconds" {
  type        = number
  description = "How long to ignore the ALB healthcheck after a task has been started."
  default     = 60
}

variable "target_container" {
  type        = string
  description = "Name of the container to be the target for requests from the load balancer"
  default     = ""
}

variable "target_container_port" {
  type        = number
  description = "Port of the target container to target by the Load balancer"
  default     = 0
}

# ----------------------------------------------------------------------
# Cloudwatch alerts
# ----------------------------------------------------------------------
variable "cloudwatch_alarms_enabled" {
  description = "Whether to create a standard set of cloudwatch alarms for the service.  Requires a notify SNS topic to have already been created for the cluster, or for cloudwatch_alert_notify_topic var to be set so that another topic is used."
  type        = bool
  default     = false
}

variable "cloudwatch_alert_notify_topic" {
  description = "The name of the SNS topic that all alerts will be sent to.  This topic will typically be used for notififations via email or slack and not to alert support teams out of hours.  If a blank string is set, the cluster notify topic will be used."
  type        = string
  default     = ""
}

variable "cloudwatch_alert_ooh_topic" {
  description = "The name of the SNS topic that out of hours alerts will be sent to.  This topic will typically be used to alert support teams out of hours.  If a blank string is set, the cluster ooh topic will be used."
  type        = string
  default     = ""
}

variable "cloudwatch_alert_to_ooh_enabled" {
  description = "Whether the alarms should also alert to the out of hours topic, as well as the notify topic.  Requires an ooh SNS topic to have already been created for the cluster, or for cloudwatch_alert_ooh_topic var to be set so that another topic is used."
  type        = bool
  default     = false
}

# Unhealthy host count alarm
variable "cloudwatch_unhealthy_host_count_enabled" {
  description = "Whether the unhealthy host count alarm should be enabled."
  type        = bool
  default     = true
}

variable "cloudwatch_unhealthy_host_count_period" {
  description = "The number of seconds that make up one monitoring period for the unhealthy host count alarm."
  type        = number
  default     = 60
}

variable "cloudwatch_unhealthy_host_count_number_of_periods" {
  description = "The number of periods that need to have passed, while exeeding the threshold, before the unhealthy host count alarm is raised."
  type        = number
  default     = 3
}

variable "cloudwatch_unhealthy_host_count_threshold" {
  description = "The number that the unhealthy hosts count must exceed per period, before the alarm is raised."
  type        = number
  default     = 0
}

# Healthy host count alarm
variable "cloudwatch_healthy_host_count_enabled" {
  description = "Whether the healthy host count alarm should be enabled."
  type        = bool
  default     = true
}

variable "cloudwatch_healthy_host_count_period" {
  description = "The number of seconds that make up one monitoring period for the healthy host count alarm."
  type        = number
  default     = 60
}

variable "cloudwatch_healthy_host_count_number_of_periods" {
  description = "The number of periods that need to have passed, while lower than the threshold, before the healthy host count alarm is raised."
  type        = number
  default     = 3
}

variable "cloudwatch_healthy_host_count_threshold" {
  description = "The number that the healthy hosts count must be lower than per period, before the alarm is raised."
  type        = number
  default     = 1
}

# Response time alarm
variable "cloudwatch_response_time_enabled" {
  description = "Whether the target reponse time alarm should be enabled."
  type        = bool
  default     = true
}

variable "cloudwatch_response_time_period" {
  description = "The number of seconds that make up one monitoring period for the target response time alarm."
  type        = number
  default     = 60
}

variable "cloudwatch_response_time_number_of_periods" {
  description = "The number of periods that need to have passed, while exeeding the threshold, before the target response time alarm is raised."
  type        = number
  default     = 3
}

variable "cloudwatch_response_time_threshold" {
  description = "The number of seconds that the target response time must exceed per period, before the alarm is raised."
  type        = number
  default     = 0.5
}

# HTTP 5xx error count alarm
variable "cloudwatch_http_5xx_error_count_enabled" {
  description = "Whether the http 5xx error count alarm should be enabled."
  type        = bool
  default     = true
}

variable "cloudwatch_http_5xx_error_count_period" {
  description = "The number of seconds that make up one monitoring period for the http 5xx error count alarm."
  type        = number
  default     = 60
}

variable "cloudwatch_http_5xx_error_count_number_of_periods" {
  description = "The number of periods that need to have passed, while exeeding the threshold, before the http 5xx error count alarm is raised."
  type        = number
  default     = 3
}

variable "cloudwatch_http_5xx_error_count_threshold" {
  description = "The number that the http 5xx error count must exceed per period, before the alarm is raised."
  type        = number
  default     = 10
}

# CPU utilisation alarm
variable "cloudwatch_cpu_utilisation_enabled" {
  description = "Whether the cpu utilisation alarm should be enabled."
  type        = bool
  default     = true
}

variable "cloudwatch_cpu_utilisation_period" {
  description = "The number of seconds that make up one monitoring period for the cpu utilisation alarm."
  type        = number
  default     = 60
}

variable "cloudwatch_cpu_utilisation_number_of_periods" {
  description = "The number of periods that need to have passed, while exeeding the threshold, before the cpu utilisation alarm is raised."
  type        = number
  default     = 3
}

variable "cloudwatch_cpu_utilisation_threshold" {
  description = "The percentage that the cpu utilisation must exceed per period, before the alarm is raised."
  type        = number
  default     = 95
}

# Memory utilisation alarm
variable "cloudwatch_memory_utilisation_enabled" {
  description = "Whether the memory utilisation alarm should be enabled."
  type        = bool
  default     = true
}

variable "cloudwatch_memory_utilisation_period" {
  description = "The number of seconds that make up one monitoring period for the memory utilisation alarm."
  type        = number
  default     = 60
}

variable "cloudwatch_memory_utilisation_number_of_periods" {
  description = "The number of periods that need to have passed, while exeeding the threshold, before the memory utilisation alarm is raised."
  type        = number
  default     = 3
}

variable "cloudwatch_memory_utilisation_threshold" {
  description = "The percentage that the memory utilisation must exceed per period, before the alarm is raised."
  type        = number
  default     = 90
}

# ------------------------------------------------------------------------------
# Optional eric reverse proxy configuration
# ------------------------------------------------------------------------------
variable "use_eric_reverse_proxy" {
  type        = bool
  description = "Whether to include the optional eric reverse proxy. If true all other eric specific variables must be provided."
  default     = false
}
variable "eric_port" {
  type        = number
  description = "The port eric should use. This must be set when using eric and must be different to the container_port when using fargate"
  default     = 0
}
variable "eric_version" {
  type        = string
  description = "The version of the docker container to run."
  default     = ""
}
variable "eric_cpus" {
  type        = number
  description = "The required cpu resource for eric. 1024 here is 1 vCPU."
  default     = 128
}
variable "eric_memory" {
  type        = number
  description = "The required memory for eric."
  default     = 256
}
variable "eric_environment" {
  type        = list(any)
  description = "The environment variables required by the service to be included in the task definition. The PORT and PROXY_TARGET_URLS env vars are automatically set to ensure the container receives all traffic and forwards to the single container behind it. The PROXY_BYPASS_PATHS is set by default to allow traffic through to the services defined healthcheck path, to add extra bypass paths use the eric_extra_bypass_paths option."
  default     = []
}
variable "eric_environment_filename" {
  type        = string
  default     = ""
  description = "s3 env file for eric reverse proxy. This value MUST only be defined when both use_eric_reverse_proxy and use_set_environment_files is set to true."
}
variable "eric_secrets" {
  type        = list(any)
  description = "The secrets required by the service to be included in the task definition. The values must be Parameter Store Secret ARNs not plaintext."
  default     = []
}
variable "eric_extra_bypass_paths" {
  type        = string
  description = "Extra proxy bypass paths to set in addition to the services defined healthcheck path. multiple paths should be separated by the '|' character e.g. /bypass-path/one|/bypass-path/two"
  default     = ""
}
variable "service_memory" {
  type        = number
  description = "Total value for service memory when other containers have been specified"
  default     = 0
}
variable "service_cpu" {
  type        = number
  description = "Total value for service cpu when other containers have been specified"
  default     = 0
}
