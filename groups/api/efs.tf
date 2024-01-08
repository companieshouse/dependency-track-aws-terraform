resource "aws_kms_key" "efs" {
  description = "KMS Key to encrypt dependency-track efs"
}

resource "aws_efs_file_system" "server_efs" {
  creation_token   = "${local.name_prefix}-efs-token"
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  encrypted        = true
  kms_key_id       = aws_kms_key.efs.arn
  tags = {
    Name = "${local.name_prefix}-efs-token"
  }
}

resource "aws_efs_access_point" "server_efs" {
  file_system_id = aws_efs_file_system.server_efs.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = 777
    }

    path = "/data"
  }
}

resource "aws_efs_file_system_policy" "server_efs" {
  file_system_id = aws_efs_file_system.server_efs.id
  policy         = data.aws_iam_policy_document.server_efs_policy.json
}

resource "aws_security_group" "efs_sg" {
  name   = "${local.name_prefix}-efs"
  vpc_id = data.aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [module.server-ecs-service.fargate_security_group_id]
  }
}

resource "aws_efs_mount_target" "server_efs" {
  file_system_id  = aws_efs_file_system.server_efs.id
  subnet_id       = data.aws_subnets.application.ids[0]
  security_groups = [aws_security_group.efs_sg.id]
}
