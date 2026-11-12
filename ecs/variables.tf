# AWS deployment region
variable "aws_region" {
  description = "AWS region for ECS deployment"
  type        = string
  default     = "ap-south-1"
}

# Existing public subnet created in your VPC lab
variable "public_subnet_id" {
  description = "Public subnet ID for ECS Fargate task"
  type        = string
}

# Project name
variable "project_name" {
  description = "ECS project name"
  type        = string
  default     = "nginx-demo"
}