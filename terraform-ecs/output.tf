# ECS cluster name
output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

# Application Load Balancer DNS
output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

# Application URL
output "application_url" {
  value = "http://${aws_lb.main.dns_name}"
}

# ECR repository URLs
output "ecr_repository_urls" {
  value = {
    for name, repo in aws_ecr_repository.service :
    name => repo.repository_url
  }
}

# GitHub Actions IAM role ARN
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

# ECS service names
output "ecs_services" {
  value = {
    for name, service in aws_ecs_service.service :
    name => service.name
  }
}

# VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# Public subnet IDs
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}