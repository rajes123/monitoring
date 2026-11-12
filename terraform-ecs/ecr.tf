# Define five microservices
locals {
  services = {
    user = {
      port     = 3001
      priority = 10
      paths    = ["/users", "/users/*"]
    }

    admin = {
      port     = 3002
      priority = 20
      paths    = ["/admin", "/admin/*"]
    }

    mobile = {
      port     = 3003
      priority = 30
      paths    = ["/mobile", "/mobile/*"]
    }

    payment = {
      port     = 3004
      priority = 40
      paths    = ["/payment", "/payment/*"]
    }

    product = {
      port     = 3005
      priority = 50
      paths    = ["/products", "/products/*"]
    }
  }
}

# Create one ECR repository per microservice
resource "aws_ecr_repository" "service" {
  for_each = local.services

  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Service = each.key
  }
}