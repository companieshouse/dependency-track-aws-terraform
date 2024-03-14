/*
* Creates a Postgres RDS instance
*/

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!?£%#*"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_security_group" "security_group" {
  name   = "${local.name_prefix}-db-sg"
  vpc_id = data.aws_vpc.vpc.id

  # Reimplement the default Security Group behaviour - allow
  # all traffic out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all traffic from within the VPC into the database
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  tags = {
    Stack       = local.stack_name
    Environment = var.environment
    Service     = local.service_name
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.0"

  identifier = local.name_prefix

  engine            = "postgres"
  engine_version    = "14.7"
  instance_class    = "db.t4g.large"
  allocated_storage = 20

  db_name                     = local.db_name
  username                    = var.db_username
  password                    = local.db_password
  manage_master_user_password = false

  vpc_security_group_ids = [aws_security_group.security_group.id]

  family = "postgres14"

  create_db_subnet_group = true
  subnet_ids             = data.aws_subnets.monitoring.ids

  deletion_protection = var.enable_deletion_protection

  create_db_option_group = false
}
