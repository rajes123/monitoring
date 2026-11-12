locals {
  name       = "${var.project_name}-${var.environment}"
  azs        = slice(data.aws_availability_zones.available.names, 0, 2)
  services   = toset(["user", "payment", "admin", "services", "order"])
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = local.name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"           = local.name
  }

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.26.0"

  name               = local.name
  kubernetes_version = var.cluster_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = { before_compute = true }
  }

  eks_managed_node_groups = {
    default = {
      name           = "${local.name}-workers"
      instance_types = var.node_instance_types
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size

      subnet_ids = module.vpc.private_subnets

      capacity_type = "ON_DEMAND"

      labels = {
        role        = "general"
        environment = var.environment
      }
    }
  }

  tags = local.common_tags
}

resource "aws_ecr_repository" "microservice" {
  for_each = local.services

  name                 = "${local.name}/${each.key}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(local.common_tags, {
    Service = each.key
  })
}

resource "aws_ecr_lifecycle_policy" "microservice" {
  for_each = aws_ecr_repository.microservice

  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the latest 20 tagged images"
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = ["v", "latest"]
        countType     = "imageCountMoreThan"
        countNumber   = 20
      }
      action = {
        type = "expire"
      }
    }]
  })
}
