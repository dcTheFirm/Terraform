terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = var.project
      ManagedBy   = "terraform"
      Environment = "test"
    }
  }
}

# Fetch current AWS account ID and region (used in ARNs later)
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}