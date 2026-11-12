variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "microservices"
}

variable "vpc_cidr" {
  description = "VPC network range"
  type        = string
  default     = "10.20.0.0/16"
}

variable "github_org" {
  description = "GitHub username or organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "Deployment branch"
  type        = string
  default     = "master"
}