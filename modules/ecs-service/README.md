<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.ecs_policy_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_policy_mem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_scheduled_action.schedule-scaledown](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_scheduled_action.schedule-scaleup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilisation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.healthy_host_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.http_5xx_error_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_utilisation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.response_time](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.unhealthy_host_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecs_service.ecs-service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.ecs-task-definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_lb_listener_rule.lb-listener-rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.ecs-target-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.ecs_service_fargate_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.fargate_ingress_cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.fargate_ingress_prefix_lists](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.fargate_ingress_security_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_lb.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_lb_listener.lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb_listener) | data source |
| [aws_sns_topic.cloudwatch_alarms_notify_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/sns_topic) | data source |
| [aws_sns_topic.cloudwatch_alarms_ooh_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/sns_topic) | data source |
| [vault_generic_secret.shared_s3](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_environment_filename"></a> [app\_environment\_filename](#input\_app\_environment\_filename) | s3 env file for application. This value MUST be defined if use\_set\_environment\_files is set to true | `string` | `""` | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | The AWS profile to use for deployment. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region for deployment. | `string` | `"eu-west-2"` | no |
| <a name="input_batch_service"></a> [batch\_service](#input\_batch\_service) | Defines whether a service is designed to be batch processing service (true) or not (false); a batch processing service will not have a target group, load balancer listener rules or a fargate security group created for it. Ideal for services that perform periodic processing or simply do not require network access | `bool` | `false` | no |
| <a name="input_cloudwatch_alarms_enabled"></a> [cloudwatch\_alarms\_enabled](#input\_cloudwatch\_alarms\_enabled) | Whether to create a standard set of cloudwatch alarms for the service.  Requires a notify SNS topic to have already been created for the cluster, or for cloudwatch\_alert\_notify\_topic var to be set so that another topic is used. | `bool` | `false` | no |
| <a name="input_cloudwatch_alert_notify_topic"></a> [cloudwatch\_alert\_notify\_topic](#input\_cloudwatch\_alert\_notify\_topic) | The name of the SNS topic that all alerts will be sent to.  This topic will typically be used for notififations via email or slack and not to alert support teams out of hours.  If a blank string is set, the cluster notify topic will be used. | `string` | `""` | no |
| <a name="input_cloudwatch_alert_ooh_topic"></a> [cloudwatch\_alert\_ooh\_topic](#input\_cloudwatch\_alert\_ooh\_topic) | The name of the SNS topic that out of hours alerts will be sent to.  This topic will typically be used to alert support teams out of hours.  If a blank string is set, the cluster ooh topic will be used. | `string` | `""` | no |
| <a name="input_cloudwatch_alert_to_ooh_enabled"></a> [cloudwatch\_alert\_to\_ooh\_enabled](#input\_cloudwatch\_alert\_to\_ooh\_enabled) | Whether the alarms should also alert to the out of hours topic, as well as the notify topic.  Requires an ooh SNS topic to have already been created for the cluster, or for cloudwatch\_alert\_ooh\_topic var to be set so that another topic is used. | `bool` | `false` | no |
| <a name="input_cloudwatch_cpu_utilisation_enabled"></a> [cloudwatch\_cpu\_utilisation\_enabled](#input\_cloudwatch\_cpu\_utilisation\_enabled) | Whether the cpu utilisation alarm should be enabled. | `bool` | `true` | no |
| <a name="input_cloudwatch_cpu_utilisation_number_of_periods"></a> [cloudwatch\_cpu\_utilisation\_number\_of\_periods](#input\_cloudwatch\_cpu\_utilisation\_number\_of\_periods) | The number of periods that need to have passed, while exeeding the threshold, before the cpu utilisation alarm is raised. | `number` | `3` | no |
| <a name="input_cloudwatch_cpu_utilisation_period"></a> [cloudwatch\_cpu\_utilisation\_period](#input\_cloudwatch\_cpu\_utilisation\_period) | The number of seconds that make up one monitoring period for the cpu utilisation alarm. | `number` | `60` | no |
| <a name="input_cloudwatch_cpu_utilisation_threshold"></a> [cloudwatch\_cpu\_utilisation\_threshold](#input\_cloudwatch\_cpu\_utilisation\_threshold) | The percentage that the cpu utilisation must exceed per period, before the alarm is raised. | `number` | `95` | no |
| <a name="input_cloudwatch_healthy_host_count_enabled"></a> [cloudwatch\_healthy\_host\_count\_enabled](#input\_cloudwatch\_healthy\_host\_count\_enabled) | Whether the healthy host count alarm should be enabled. | `bool` | `true` | no |
| <a name="input_cloudwatch_healthy_host_count_number_of_periods"></a> [cloudwatch\_healthy\_host\_count\_number\_of\_periods](#input\_cloudwatch\_healthy\_host\_count\_number\_of\_periods) | The number of periods that need to have passed, while lower than the threshold, before the healthy host count alarm is raised. | `number` | `3` | no |
| <a name="input_cloudwatch_healthy_host_count_period"></a> [cloudwatch\_healthy\_host\_count\_period](#input\_cloudwatch\_healthy\_host\_count\_period) | The number of seconds that make up one monitoring period for the healthy host count alarm. | `number` | `60` | no |
| <a name="input_cloudwatch_healthy_host_count_threshold"></a> [cloudwatch\_healthy\_host\_count\_threshold](#input\_cloudwatch\_healthy\_host\_count\_threshold) | The number that the healthy hosts count must be lower than per period, before the alarm is raised. | `number` | `1` | no |
| <a name="input_cloudwatch_http_5xx_error_count_enabled"></a> [cloudwatch\_http\_5xx\_error\_count\_enabled](#input\_cloudwatch\_http\_5xx\_error\_count\_enabled) | Whether the http 5xx error count alarm should be enabled. | `bool` | `true` | no |
| <a name="input_cloudwatch_http_5xx_error_count_number_of_periods"></a> [cloudwatch\_http\_5xx\_error\_count\_number\_of\_periods](#input\_cloudwatch\_http\_5xx\_error\_count\_number\_of\_periods) | The number of periods that need to have passed, while exeeding the threshold, before the http 5xx error count alarm is raised. | `number` | `3` | no |
| <a name="input_cloudwatch_http_5xx_error_count_period"></a> [cloudwatch\_http\_5xx\_error\_count\_period](#input\_cloudwatch\_http\_5xx\_error\_count\_period) | The number of seconds that make up one monitoring period for the http 5xx error count alarm. | `number` | `60` | no |
| <a name="input_cloudwatch_http_5xx_error_count_threshold"></a> [cloudwatch\_http\_5xx\_error\_count\_threshold](#input\_cloudwatch\_http\_5xx\_error\_count\_threshold) | The number that the http 5xx error count must exceed per period, before the alarm is raised. | `number` | `10` | no |
| <a name="input_cloudwatch_memory_utilisation_enabled"></a> [cloudwatch\_memory\_utilisation\_enabled](#input\_cloudwatch\_memory\_utilisation\_enabled) | Whether the memory utilisation alarm should be enabled. | `bool` | `true` | no |
| <a name="input_cloudwatch_memory_utilisation_number_of_periods"></a> [cloudwatch\_memory\_utilisation\_number\_of\_periods](#input\_cloudwatch\_memory\_utilisation\_number\_of\_periods) | The number of periods that need to have passed, while exeeding the threshold, before the memory utilisation alarm is raised. | `number` | `3` | no |
| <a name="input_cloudwatch_memory_utilisation_period"></a> [cloudwatch\_memory\_utilisation\_period](#input\_cloudwatch\_memory\_utilisation\_period) | The number of seconds that make up one monitoring period for the memory utilisation alarm. | `number` | `60` | no |
| <a name="input_cloudwatch_memory_utilisation_threshold"></a> [cloudwatch\_memory\_utilisation\_threshold](#input\_cloudwatch\_memory\_utilisation\_threshold) | The percentage that the memory utilisation must exceed per period, before the alarm is raised. | `number` | `90` | no |
| <a name="input_cloudwatch_response_time_enabled"></a> [cloudwatch\_response\_time\_enabled](#input\_cloudwatch\_response\_time\_enabled) | Whether the target reponse time alarm should be enabled. | `bool` | `true` | no |
| <a name="input_cloudwatch_response_time_number_of_periods"></a> [cloudwatch\_response\_time\_number\_of\_periods](#input\_cloudwatch\_response\_time\_number\_of\_periods) | The number of periods that need to have passed, while exeeding the threshold, before the target response time alarm is raised. | `number` | `3` | no |
| <a name="input_cloudwatch_response_time_period"></a> [cloudwatch\_response\_time\_period](#input\_cloudwatch\_response\_time\_period) | The number of seconds that make up one monitoring period for the target response time alarm. | `number` | `60` | no |
| <a name="input_cloudwatch_response_time_threshold"></a> [cloudwatch\_response\_time\_threshold](#input\_cloudwatch\_response\_time\_threshold) | The number of seconds that the target response time must exceed per period, before the alarm is raised. | `number` | `0.5` | no |
| <a name="input_cloudwatch_unhealthy_host_count_enabled"></a> [cloudwatch\_unhealthy\_host\_count\_enabled](#input\_cloudwatch\_unhealthy\_host\_count\_enabled) | Whether the unhealthy host count alarm should be enabled. | `bool` | `true` | no |
| <a name="input_cloudwatch_unhealthy_host_count_number_of_periods"></a> [cloudwatch\_unhealthy\_host\_count\_number\_of\_periods](#input\_cloudwatch\_unhealthy\_host\_count\_number\_of\_periods) | The number of periods that need to have passed, while exeeding the threshold, before the unhealthy host count alarm is raised. | `number` | `3` | no |
| <a name="input_cloudwatch_unhealthy_host_count_period"></a> [cloudwatch\_unhealthy\_host\_count\_period](#input\_cloudwatch\_unhealthy\_host\_count\_period) | The number of seconds that make up one monitoring period for the unhealthy host count alarm. | `number` | `60` | no |
| <a name="input_cloudwatch_unhealthy_host_count_threshold"></a> [cloudwatch\_unhealthy\_host\_count\_threshold](#input\_cloudwatch\_unhealthy\_host\_count\_threshold) | The number that the unhealthy hosts count must exceed per period, before the alarm is raised. | `number` | `0` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | The port the container exposes. This must match the port used by the service in its environment variables. | `number` | `9000` | no |
| <a name="input_container_version"></a> [container\_version](#input\_container\_version) | The version of the docker container to run. | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of default tags to be added to the resources | `map(any)` | `{}` | no |
| <a name="input_desired_task_count"></a> [desired\_task\_count](#input\_desired\_task\_count) | The desired ECS task count for this service | `number` | `1` | no |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | The FQDN of the docker registry. | `string` | n/a | yes |
| <a name="input_docker_repo"></a> [docker\_repo](#input\_docker\_repo) | The repository to use with in the given docker registry. | `string` | n/a | yes |
| <a name="input_ecs_cluster_id"></a> [ecs\_cluster\_id](#input\_ecs\_cluster\_id) | The ID of the ECS cluster the ECS service will be created in. | `string` | n/a | yes |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Whether to enable the use of ECS Exec for the service.  If enabled, a suitable task\_role\_arn, such as the one created at cluster level, must be supplied. | `bool` | `false` | no |
| <a name="input_enable_listener"></a> [enable\_listener](#input\_enable\_listener) | If true, enable listener will create the listener rules.  If false the listener rules will not be created.  This variable can be defined in the service. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name, defined in envrionments vars. | `string` | n/a | yes |
| <a name="input_environment_files"></a> [environment\_files](#input\_environment\_files) | The environment files to define variables needed by the ecs service tasks. These file will be ignored when use\_set\_environment\_files is set to true. | `list(any)` | `[]` | no |
| <a name="input_eric_cpus"></a> [eric\_cpus](#input\_eric\_cpus) | The required cpu resource for eric. 1024 here is 1 vCPU. | `number` | `128` | no |
| <a name="input_eric_environment"></a> [eric\_environment](#input\_eric\_environment) | The environment variables required by the service to be included in the task definition. The PORT and PROXY\_TARGET\_URLS env vars are automatically set to ensure the container receives all traffic and forwards to the single container behind it. The PROXY\_BYPASS\_PATHS is set by default to allow traffic through to the services defined healthcheck path, to add extra bypass paths use the eric\_extra\_bypass\_paths option. | `list(any)` | `[]` | no |
| <a name="input_eric_environment_filename"></a> [eric\_environment\_filename](#input\_eric\_environment\_filename) | s3 env file for eric reverse proxy. This value MUST only be defined when both use\_eric\_reverse\_proxy and use\_set\_environment\_files is set to true. | `string` | `""` | no |
| <a name="input_eric_extra_bypass_paths"></a> [eric\_extra\_bypass\_paths](#input\_eric\_extra\_bypass\_paths) | Extra proxy bypass paths to set in addition to the services defined healthcheck path. multiple paths should be separated by the '\|' character e.g. /bypass-path/one\|/bypass-path/two | `string` | `""` | no |
| <a name="input_eric_memory"></a> [eric\_memory](#input\_eric\_memory) | The required memory for eric. | `number` | `256` | no |
| <a name="input_eric_port"></a> [eric\_port](#input\_eric\_port) | The port eric should use. This must be set when using eric and must be different to the container\_port when using fargate | `number` | `0` | no |
| <a name="input_eric_secrets"></a> [eric\_secrets](#input\_eric\_secrets) | The secrets required by the service to be included in the task definition. The values must be Parameter Store Secret ARNs not plaintext. | `list(any)` | `[]` | no |
| <a name="input_eric_version"></a> [eric\_version](#input\_eric\_version) | The version of the docker container to run. | `string` | `""` | no |
| <a name="input_fargate_ingress_cidrs"></a> [fargate\_ingress\_cidrs](#input\_fargate\_ingress\_cidrs) | A list of CIDR blocks that will be allowed ingress access to the fargate instances | `list(string)` | `[]` | no |
| <a name="input_fargate_ingress_prefix_list_ids"></a> [fargate\_ingress\_prefix\_list\_ids](#input\_fargate\_ingress\_prefix\_list\_ids) | A list of prefix list IDs that will be allowed ingress access to the fargate instances | `list(string)` | `[]` | no |
| <a name="input_fargate_ingress_security_group_ids"></a> [fargate\_ingress\_security\_group\_ids](#input\_fargate\_ingress\_security\_group\_ids) | A list of security group IDs that will be allowed ingress access to the fargate instances | `list(string)` | `[]` | no |
| <a name="input_fargate_permit_existing_alb"></a> [fargate\_permit\_existing\_alb](#input\_fargate\_permit\_existing\_alb) | Defines whether an already existing ALB is being used and should be permitted access via the fargate security group. If true, a rule will be added permitting ingress from the ALB's security group. Should be defined as false if the ALB doesn't yet exist or if the rule is not desired. | `bool` | `true` | no |
| <a name="input_fargate_subnets"></a> [fargate\_subnets](#input\_fargate\_subnets) | The subnets to use when running the service with fargate | `list(string)` | `[]` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | How long to ignore the ALB healthcheck after a task has been started. | `number` | `60` | no |
| <a name="input_healthcheck_healthy_threshold"></a> [healthcheck\_healthy\_threshold](#input\_healthcheck\_healthy\_threshold) | The number of healthchecks required to become healthy. | `string` | `"3"` | no |
| <a name="input_healthcheck_interval"></a> [healthcheck\_interval](#input\_healthcheck\_interval) | The interval between service healthchecks. | `string` | `"30"` | no |
| <a name="input_healthcheck_matcher"></a> [healthcheck\_matcher](#input\_healthcheck\_matcher) | The expected response code to pass service healthchecks. | `string` | `"200"` | no |
| <a name="input_healthcheck_path"></a> [healthcheck\_path](#input\_healthcheck\_path) | The path to use to perform service healthchecks. | `string` | `"/healthcheck"` | no |
| <a name="input_healthcheck_unhealthy_threshold"></a> [healthcheck\_unhealthy\_threshold](#input\_healthcheck\_unhealthy\_threshold) | The number of healthchecks required to become unhealthy. | `string` | `"3"` | no |
| <a name="input_lb_listener_arn"></a> [lb\_listener\_arn](#input\_lb\_listener\_arn) | The ARN of the load balancer the ECS service will sit behind. | `string` | `""` | no |
| <a name="input_lb_listener_paths"></a> [lb\_listener\_paths](#input\_lb\_listener\_paths) | The path regex patterns that this service controls. Traffic to the load balancer will only be sent to this ECS service if it matches one of these defined path patterns. | `list(string)` | `[]` | no |
| <a name="input_lb_listener_rule_priority"></a> [lb\_listener\_rule\_priority](#input\_lb\_listener\_rule\_priority) | The priority to use when attaching the services listener rules to the load balancer. | `number` | `1` | no |
| <a name="input_max_task_count"></a> [max\_task\_count](#input\_max\_task\_count) | The maximum number of tasks for this service. | `number` | `2` | no |
| <a name="input_min_task_count"></a> [min\_task\_count](#input\_min\_task\_count) | The minimum number of tasks for this service. | `number` | `1` | no |
| <a name="input_mount_points"></a> [mount\_points](#input\_mount\_points) | Used to define mount points in the container definition | `list` | `[]` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The user friendly name prefix used to name AWS resources. | `string` | n/a | yes |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK\_DEFINITION. | `string` | `"TASK_DEFINITION"` | no |
| <a name="input_required_cpus"></a> [required\_cpus](#input\_required\_cpus) | The required cpu resource for this service. 1024 here is 1 vCPU | `number` | `128` | no |
| <a name="input_required_memory"></a> [required\_memory](#input\_required\_memory) | The required memory for this service | `number` | `256` | no |
| <a name="input_service_autoscale_enabled"></a> [service\_autoscale\_enabled](#input\_service\_autoscale\_enabled) | Whether to enable service autoscaling, including scheduled autoscaling | `bool` | `false` | no |
| <a name="input_service_autoscale_scale_in_cooldown"></a> [service\_autoscale\_scale\_in\_cooldown](#input\_service\_autoscale\_scale\_in\_cooldown) | Cooldown in seconds for ECS Service scale in | `number` | `300` | no |
| <a name="input_service_autoscale_scale_out_cooldown"></a> [service\_autoscale\_scale\_out\_cooldown](#input\_service\_autoscale\_scale\_out\_cooldown) | Cooldown in seconds for ECS Service scale out | `number` | `300` | no |
| <a name="input_service_autoscale_target_value_cpu"></a> [service\_autoscale\_target\_value\_cpu](#input\_service\_autoscale\_target\_value\_cpu) | Target CPU percentage for the ECS Service to autoscale on | `number` | `100` | no |
| <a name="input_service_autoscale_target_value_mem"></a> [service\_autoscale\_target\_value\_mem](#input\_service\_autoscale\_target\_value\_mem) | Target Memory Utilisation percentage for the ECS Service to autoscale on | `number` | `100` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The user friendly service name used to name AWS resources. | `string` | n/a | yes |
| <a name="input_service_scaledown_schedule"></a> [service\_scaledown\_schedule](#input\_service\_scaledown\_schedule) | The schedule to use when scaling down the number of tasks to zero. | `string` | `""` | no |
| <a name="input_service_scaleup_schedule"></a> [service\_scaleup\_schedule](#input\_service\_scaleup\_schedule) | The schedule to use when scaling up the number of tasks to their normal desired level. | `string` | `""` | no |
| <a name="input_task_environment"></a> [task\_environment](#input\_task\_environment) | The environment variables required by the service to be included in the task definition | `list(any)` | `[]` | no |
| <a name="input_task_execution_role_arn"></a> [task\_execution\_role\_arn](#input\_task\_execution\_role\_arn) | The ARN of the IAM role to use to create and launch the ECS service tasks. | `string` | n/a | yes |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | The ARN of the IAM role used by the ECS tasks while running. If left blank, a task role will not be used. | `string` | `""` | no |
| <a name="input_task_secrets"></a> [task\_secrets](#input\_task\_secrets) | The secrets required by the service to be included in the task definition. The values must be Parameter Store Secret ARNs not plaintext. | `list(any)` | `[]` | no |
| <a name="input_ulimits"></a> [ulimits](#input\_ulimits) | Configuration for ulimit values that the containers use | <pre>list(object({<br>    hardLimit = number<br>    name      = string<br>    softLimit = number<br>  }))</pre> | `[]` | no |
| <a name="input_use_capacity_provider"></a> [use\_capacity\_provider](#input\_use\_capacity\_provider) | Whether to use a capacity provider instead of setting a launch type for the service | `bool` | `false` | no |
| <a name="input_use_eric_reverse_proxy"></a> [use\_eric\_reverse\_proxy](#input\_use\_eric\_reverse\_proxy) | Whether to include the optional eric reverse proxy. If true all other eric specific variables must be provided. | `bool` | `false` | no |
| <a name="input_use_fargate"></a> [use\_fargate](#input\_use\_fargate) | If true, sets the required capabilities for all containers in the task definition to use FARGATE, false uses EC2 | `bool` | `false` | no |
| <a name="input_use_set_environment_files"></a> [use\_set\_environment\_files](#input\_use\_set\_environment\_files) | Toggle default global and shared  environment files. If this is set to true, the global and shared files for the environment will be used. The app\_environment\_filename MUST also be defined if this is set to true | `bool` | `false` | no |
| <a name="input_use_task_container_healthcheck"></a> [use\_task\_container\_healthcheck](#input\_use\_task\_container\_healthcheck) | If true, sets the ECS Tasks' container health check | `bool` | `false` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Configuration block for volumes that containers in your task may use | `any` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in use for the ECS cluster and associated resources e.g. ALBs. | `string` | n/a | yes |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | Optional flag for TF to wait for the service to go into a steady state | `string` | `"true"` | no |
| <a name="additional_sidecar_containers"></a> [additional\_sidecar\_containers](#additional\_sidecar\_containers) | Optional list of Container Definitions to deploy alongside the primary container specified which will act as side-car containers. When there are values, the objects must have the following attributes: `name` (_string_), `image` (_string_), `memory` (_number_) and `cpu` (_number_), they can also specify `depends_on` (`list` of `object`s with `container_name` (_string_) and optional `condition` (_string_ defaults to "START")), `port_mappings` (`list` of `objects` with `container_port` (_number_), `host_port` (_number_) and optionally `protocol` (_string_ defaults to `tcp`)) and `essential` (_boolean_ defaults to true) | `list(object)` | `[]` | no |
| <a name="ecs_cluster_name"></a> [ecs\_cluster\_name](#ecs\_cluster\_name) | Sets the name of the cluster where it is different from `${var.name_prefix}-stack` | `string` | `""` | no |
| <a name="target_container_name"></a> [target\_container\_name](#target\_container\_name) | Sets the name of the container specified in the containers to target from the ALB | `string` | `""` | no |
| <a name="target_container_port"></a> [target\_container\_port](#target\_container\_port) | Sets the port on the container to target from the ALB on the required container | `string` | `""` | no |
| <a name="total_service_memory"></a> [total\_service\_memory](#total\_service\_memory) | Sets the overall memory assigned to the service (i.e. providing an allocation of memory for the whole service - to allow for the sum of memory of all containers defined in the task definition) | `number` | `0` | no |
| <a name="total_service_cpu"></a> [total\_service\_cpu](#total\_service\_cpu) | Sets the overall cpu assigned to the service (i.e. providing an allocation of cpu for the whole service - to allow for the sum of cpu of all containers defined in the task definition) | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fargate_security_group_id"></a> [fargate\_security\_group\_id](#output\_fargate\_security\_group\_id) | n/a |
<!-- END_TF_DOCS -->
