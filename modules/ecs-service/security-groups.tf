resource "aws_security_group" "ecs_service_fargate_sg" {
  count       = var.use_fargate ? 1 : 0
  description = "Security group for fargate ecs service"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.fargate_permit_existing_alb && local.create_fargate_lb_ingress ? [1] : []

    content {
      from_port       = local.traffic_port
      to_port         = local.traffic_port
      protocol        = "tcp"
      security_groups = data.aws_lb.lb[0].security_groups
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags, {
    Environment = var.environment
    Name        = "${var.environment}-${var.service_name}-sg"
  })
}

resource "aws_security_group_rule" "fargate_ingress_cidrs" {
  for_each = var.use_fargate ? toset(var.fargate_ingress_cidrs) : toset([])

  description       = "Ingress from ${each.value}"
  type              = "ingress"
  from_port         = local.traffic_port
  to_port           = local.traffic_port
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.ecs_service_fargate_sg[0].id
}

resource "aws_security_group_rule" "fargate_ingress_security_groups" {
  for_each = var.use_fargate ? toset(var.fargate_ingress_security_group_ids) : toset([])

  description              = "Ingress from ${each.value}"
  type                     = "ingress"
  from_port                = local.traffic_port
  to_port                  = local.traffic_port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.ecs_service_fargate_sg[0].id
}

resource "aws_security_group_rule" "fargate_ingress_prefix_lists" {
  for_each = var.use_fargate ? toset(var.fargate_ingress_prefix_list_ids) : toset([])

  description       = "Ingress from ${each.value}"
  type              = "ingress"
  from_port         = local.traffic_port
  to_port           = local.traffic_port
  protocol          = "tcp"
  prefix_list_ids   = [each.value]
  security_group_id = aws_security_group.ecs_service_fargate_sg[0].id
}
