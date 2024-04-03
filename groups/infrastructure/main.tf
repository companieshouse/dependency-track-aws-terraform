provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      StackName   = local.stack_name
      Terraform   = true
      Version     = var.version
      Repository  = "companieshouse/dependency-track-aws-terraform"
    }
  }
}

terraform {
  backend "s3" {
  }
  required_version = "~> 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.18.0"
    }
  }
}
