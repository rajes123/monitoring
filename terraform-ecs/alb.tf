# ------------------------------------------------
# 1. CREATE APPLICATION LOAD BALANCER
# ------------------------------------------------

resource "aws_lb" "main" {
  name               = "microservices-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = aws_subnet.public[*].id

  tags = {
    Name = "microservices-alb"
  }
}

# ------------------------------------------------
# 2. CREATE FIVE TARGET GROUPS
# ------------------------------------------------

resource "aws_lb_target_group" "service" {
  for_each = local.services

  name        = "${each.key}-tg"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  # Check whether the Node.js service is healthy
  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Service = each.key
  }
}

# ------------------------------------------------
# 3. CREATE HTTP LISTENER
# ------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn

  port     = 80
  protocol = "HTTP"

  # Return 404 for unmatched paths
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Microservice route not found"
      status_code  = "404"
    }
  }
}

# ------------------------------------------------
# 4. CREATE PATH-BASED ROUTING RULES
# ------------------------------------------------

resource "aws_lb_listener_rule" "service" {
  for_each = local.services

  listener_arn = aws_lb_listener.http.arn

  priority = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.paths
    }
  }
}