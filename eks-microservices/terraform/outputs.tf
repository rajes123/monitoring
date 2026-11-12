output "aws_region" {
  value = var.aws_region
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_urls" {
  description = "Map of microservice name to ECR repository URL."
  value       = { for name, repo in aws_ecr_repository.microservice : name => repo.repository_url }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "worker_node_group" {
  value = keys(module.eks.eks_managed_node_groups)
}
