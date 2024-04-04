provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.default_tags
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
