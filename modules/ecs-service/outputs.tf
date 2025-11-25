output "fargate_security_group_id" {
  value = var.use_fargate ? aws_security_group.ecs_service_fargate_sg[0].id : ""
}
