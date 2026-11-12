terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.70.0"
    }
  }
  backend "local" {
    path = "terraform.tfstate"
  }
  # backend "s3" {
  #   bucket = "terraform-config90"
  #   key = "./terraform.tfstate"
  #   region = "ap-south-1"
  #   encrypt = true
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.aws_region
}