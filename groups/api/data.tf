data "vault_generic_secret" "secrets" {
  path = "applications/${var.aws_profile}/${var.environment}/${local.stack_name}-stack"
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_ssm_parameter" "alb_name" {
  name = local.alb_name_parameter_name
}

data "aws_lb" "dependency-track-lb" {
  name = data.aws_ssm_parameter.alb_name.value
}

data "aws_lb_listener" "dependency-track-lb-listener" {
  load_balancer_arn = data.aws_lb.dependency-track-lb.arn
  port              = 443
}

data "aws_ssm_parameter" "stack_cluster_name" {
  name            = "/${local.name_prefix}/stack-cluster-name"
  with_decryption = true
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = local.ecs_cluster_name
}

#Get application subnet IDs
data "aws_subnets" "monitoring" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = [local.monitoring_subnets_name_pattern]
  }
}

# retrieve all secrets for this stack using the stack path
data "aws_ssm_parameters_by_path" "secrets" {
  path = "/${local.name_prefix}"
}

# create a list of secrets names to retrieve them in a nicer format and lookup each secret by name
data "aws_ssm_parameter" "secret" {
  for_each = toset(data.aws_ssm_parameters_by_path.secrets.names)
  name     = each.key
}

data "aws_iam_role" "ecs-task-execution-role" {
  name = "${local.name_prefix}-ecs-task-execution-role"
}


data "aws_iam_policy_document" "server_efs_policy" {
  statement {
    sid    = "WritePolicy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]

    resources = [aws_efs_file_system.server_efs.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

data "aws_ssm_parameter" "kms_key_alias" {
  name            = "/${local.name_prefix}/kms_key_alias"
  with_decryption = true
}

data "aws_kms_key" "kms_key" {
  key_id = data.aws_ssm_parameter.kms_key_alias.value
}
