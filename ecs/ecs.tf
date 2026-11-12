# --------------------------------------------------
# ECS CLUSTER + ECS SERVICE
# --------------------------------------------------

module "ecs" {

  # Official AWS ECS Terraform module
  source  = "terraform-aws-modules/ecs/aws"
  version = "7.6.1"

  # ECS cluster name
  cluster_name = "${var.project_name}-cluster"

  # Enable Fargate capacity provider
  # We don't need EC2 instances for this example
  cluster_capacity_providers = ["FARGATE"]

  # Run tasks using Fargate
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 1
    }
  }

  # --------------------------------------------------
  # ECS SERVICE
  # --------------------------------------------------

  services = {

    nginx-service = {

      # Task CPU: 0.25 vCPU
      cpu = 256

      # Task memory: 512 MB
      memory = 512

      # Run only one ECS task
      desired_count = 1

      # Disable automatic scaling for this learning example
      enable_autoscaling = false

      # Use our existing public subnet
      subnet_ids = [var.public_subnet_id]

      # Assign a public IP to the Fargate task
      # This allows browser access through the internet
      assign_public_ip = true

      # --------------------------------------------------
      # SECURITY GROUP
      # --------------------------------------------------

      security_group_ingress_rules = {

        # Allow HTTP traffic on port 80
        http = {
          description = "Allow HTTP traffic for Nginx"
          from_port   = 80
          to_port     = 80
          ip_protocol = "tcp"

          # Open for learning/testing only
          cidr_ipv4 = "0.0.0.0/0"
        }
      }

      security_group_egress_rules = {

        # Allow outbound traffic
        all = {
          ip_protocol = "-1"
          cidr_ipv4   = "0.0.0.0/0"
        }
      }

      # --------------------------------------------------
      # CONTAINER DEFINITION
      # --------------------------------------------------

      container_definitions = {

        nginx = {

          # Official lightweight Nginx Alpine image
          image = "nginx:alpine"

          # Container name
          essential = true

          # Container CPU allocation
          cpu = 256

          # Container memory allocation
          memory = 512

          # Expose Nginx port 80
          portMappings = [
            {
              name          = "nginx"
              containerPort = 80
              protocol      = "tcp"
            }
          ]

          # Enable CloudWatch container logging
          enable_cloudwatch_logging = false

          # Create a dedicated CloudWatch log group
          create_cloudwatch_log_group = false

          cloudwatch_log_group_name = "/ecs/${var.project_name}/nginx"

          # Keep logs for 7 days to reduce storage costs
          cloudwatch_log_group_retention_in_days = 7

          # Keep the container filesystem writable
          # for this simple learning example
          readonlyRootFilesystem = false
        }
      }

      # Tags for ECS service resources
      tags = {
        Environment = "dev"
        Application = "Nginx"
      }
    }
  }

  # Cluster tags
  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}