resource "aws_cloudwatch_metric_alarm" "unhealthy_host_count" {
  count = var.cloudwatch_alarms_enabled && var.cloudwatch_unhealthy_host_count_enabled ? 1 : 0

  alarm_name          = "${local.ecs_cluster_name}-tg-${var.service_name}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_unhealthy_host_count_number_of_periods
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_unhealthy_host_count_period
  statistic           = "Minimum"
  threshold           = var.cloudwatch_unhealthy_host_count_threshold
  alarm_description   = format("Unhealthy host count is greater than %s", var.cloudwatch_unhealthy_host_count_threshold)
  alarm_actions       = local.cloudwatch_sns_topics
  ok_actions          = local.cloudwatch_sns_topics
  treat_missing_data  = "notBreaching"

  dimensions = {
    "TargetGroup"  = aws_lb_target_group.ecs-target-group[0].arn_suffix
    "LoadBalancer" = data.aws_lb.lb[0].arn_suffix
  }

  depends_on = [
    aws_lb_target_group.ecs-target-group
  ]
}

resource "aws_cloudwatch_metric_alarm" "healthy_host_count" {
  count = var.cloudwatch_alarms_enabled && var.cloudwatch_healthy_host_count_enabled ? 1 : 0

  alarm_name          = "${local.ecs_cluster_name}-tg-${var.service_name}-healthy-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.cloudwatch_healthy_host_count_number_of_periods
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_healthy_host_count_period
  statistic           = "Maximum"
  threshold           = var.cloudwatch_healthy_host_count_threshold
  alarm_description   = format("Healthy host count is less than %s", var.cloudwatch_healthy_host_count_threshold)
  alarm_actions       = local.cloudwatch_sns_topics
  ok_actions          = local.cloudwatch_sns_topics
  treat_missing_data  = "breaching"

  dimensions = {
    "TargetGroup"  = aws_lb_target_group.ecs-target-group[0].arn_suffix
    "LoadBalancer" = data.aws_lb.lb[0].arn_suffix
  }

  depends_on = [
    aws_lb_target_group.ecs-target-group
  ]
}

resource "aws_cloudwatch_metric_alarm" "response_time" {
  count = var.cloudwatch_alarms_enabled && var.cloudwatch_response_time_enabled ? 1 : 0

  alarm_name          = "${local.ecs_cluster_name}-tg-${var.service_name}-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_response_time_number_of_periods
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_response_time_period
  statistic           = "Average"
  threshold           = var.cloudwatch_response_time_threshold
  alarm_description   = format("Response time is greater than %s", var.cloudwatch_response_time_threshold)
  alarm_actions       = local.cloudwatch_sns_topics
  ok_actions          = local.cloudwatch_sns_topics
  treat_missing_data  = "notBreaching"

  dimensions = {
    "TargetGroup"  = aws_lb_target_group.ecs-target-group[0].arn_suffix
    "LoadBalancer" = data.aws_lb.lb[0].arn_suffix
  }

  depends_on = [
    aws_lb_target_group.ecs-target-group
  ]
}

resource "aws_cloudwatch_metric_alarm" "http_5xx_error_count" {
  count = var.cloudwatch_alarms_enabled && var.cloudwatch_http_5xx_error_count_enabled ? 1 : 0

  alarm_name          = "${local.ecs_cluster_name}-tg-${var.service_name}-5xx-error-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_http_5xx_error_count_number_of_periods
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.cloudwatch_http_5xx_error_count_period
  statistic           = "Maximum"
  threshold           = var.cloudwatch_http_5xx_error_count_threshold
  alarm_description   = format("5xx error count is greater than %s", var.cloudwatch_http_5xx_error_count_threshold)
  alarm_actions       = local.cloudwatch_sns_topics
  ok_actions          = local.cloudwatch_sns_topics
  treat_missing_data  = "notBreaching"

  dimensions = {
    "TargetGroup"  = aws_lb_target_group.ecs-target-group[0].arn_suffix
    "LoadBalancer" = data.aws_lb.lb[0].arn_suffix
  }

  depends_on = [
    aws_lb_target_group.ecs-target-group
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilisation" {
  count = var.cloudwatch_alarms_enabled && var.cloudwatch_cpu_utilisation_enabled ? 1 : 0

  alarm_name          = "${local.ecs_cluster_name}-${var.service_name}-cpu-utilisation"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_cpu_utilisation_number_of_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cloudwatch_cpu_utilisation_period
  statistic           = "Average"
  threshold           = var.cloudwatch_cpu_utilisation_threshold
  alarm_description   = format("CPU utilisation is greater than %s%%", var.cloudwatch_cpu_utilisation_threshold)
  alarm_actions       = local.cloudwatch_sns_topics
  ok_actions          = local.cloudwatch_sns_topics
  treat_missing_data  = "notBreaching"

  dimensions = {
    "ClusterName" = local.ecs_cluster_name
    "ServiceName" = "${var.environment}-${var.service_name}"
  }

  depends_on = [
    aws_ecs_service.ecs-service
  ]
}

resource "aws_cloudwatch_metric_alarm" "memory_utilisation" {
  count = var.cloudwatch_alarms_enabled && var.cloudwatch_memory_utilisation_enabled ? 1 : 0

  alarm_name          = "${local.ecs_cluster_name}-${var.service_name}-memory-utilisation"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cloudwatch_memory_utilisation_number_of_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.cloudwatch_memory_utilisation_period
  statistic           = "Average"
  threshold           = var.cloudwatch_memory_utilisation_threshold
  alarm_description   = format("Memory utilisation is greater than %s%%", var.cloudwatch_memory_utilisation_threshold)
  alarm_actions       = local.cloudwatch_sns_topics
  ok_actions          = local.cloudwatch_sns_topics
  treat_missing_data  = "notBreaching"

  dimensions = {
    "ClusterName" = local.ecs_cluster_name
    "ServiceName" = "${var.environment}-${var.service_name}"
  }

  depends_on = [
    aws_ecs_service.ecs-service
  ]
}
