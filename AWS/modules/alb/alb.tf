#-------------------------------------------------------------------------------
# To create resources run:
# terraform apply -target=module.alb
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Defines ALB Security Group
#-------------------------------------------------------------------------------
resource "aws_security_group" "albSG" {
  name        = "albSG"
  description = "Enable HTTP and HTTPS access via ports 80 and 443"
  vpc_id      = var.vpcId

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name          = "albSG"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

#-------------------------------------------------------------------------------
# Defines ALB
#-------------------------------------------------------------------------------
resource "aws_lb" "appLB" {
  name               = "appLB"
  ip_address_type    = "ipv4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.albSG.id]
  subnets            = [var.publicSubnet0id, var.publicSubnet1id]

  tags = {
    Name          = "appLB"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

#-------------------------------------------------------------------------------
# Defines HTTP, HTTPS Listeners
#-------------------------------------------------------------------------------
resource "aws_lb_listener" "httpListener" {
  load_balancer_arn = aws_lb.appLB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "httpsListener" {
  load_balancer_arn = aws_lb.appLB.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certArn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.defaultTG.arn
  }
}

#-------------------------------------------------------------------------------
# Defines Default Target Group
#-------------------------------------------------------------------------------
resource "aws_lb_target_group" "defaultTG" {
  name        = "defaultTG"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpcId
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    protocol            = "HTTP"
    path                = "/"
    interval            = 11
    matcher             = "200-299"
  }
  tags = {
    Name          = "defaultTG"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}
