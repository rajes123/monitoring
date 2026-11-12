# ------------------------------------------------
# 1. CREATE ECS CLUSTER
# ------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "microservices-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "microservices-cluster"
    Environment = "Development"
  }
}

# ------------------------------------------------
# 2. CREATE CLOUDWATCH LOG GROUPS
# ------------------------------------------------

resource "aws_cloudwatch_log_group" "service" {
  for_each = local.services

  name              = "/ecs/microservices/${each.key}"
  retention_in_days = 7
}

# ------------------------------------------------
# 3. CREATE TASK DEFINITIONS
# ------------------------------------------------

resource "aws_ecs_task_definition" "service" {
  for_each = local.services

  family = each.key

  # Fargate requires awsvpc networking
  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  # Lightweight starting configuration
  cpu    = "256"
  memory = "512"

  # IAM roles
  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  # Initial placeholder image.
  # GitHub Actions replaces this image with your real application.
  container_definitions = jsonencode([
    {
      name      = each.key
      image     = "public.ecr.aws/docker/library/nginx:alpine"
      essential = true

      portMappings = [
        {
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.service[each.key].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Service = each.key
  }
}

# ------------------------------------------------
# 4. CREATE FIVE ECS SERVICES
# ------------------------------------------------

resource "aws_ecs_service" "service" {
  for_each = local.services

  name = "${each.key}-service"

  cluster = aws_ecs_cluster.main.id

  task_definition = aws_ecs_task_definition.service[each.key].arn

  # Start with zero tasks.
  # GitHub Actions will increase this to one after deployment.
  desired_count = 0

  launch_type = "FARGATE"

  # Fargate task networking
  network_configuration {
    subnets = aws_subnet.public[*].id

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = true
  }

  # Connect the service to its own ALB target group
  load_balancer {
    target_group_arn = aws_lb_target_group.service[each.key].arn

    container_name = each.key
    container_port = each.value.port
  }

  # ECS deployment health configuration
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = {
    Service = each.key
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution,
    aws_lb_listener_rule.service
  ]
}