# Display ECS cluster name
output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

# Display AWS region
output "aws_region" {
  value = var.aws_region
}

# Display the subnet used by ECS
output "public_subnet_id" {
  value = var.public_subnet_id
}

# Display the CloudWatch log group
output "nginx_log_group" {
  value = "/ecs/${var.project_name}/nginx"
}