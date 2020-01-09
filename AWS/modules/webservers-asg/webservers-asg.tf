variable "vpc-id" {}
variable "public-subnet-0-id" {}
variable "public-subnet-1-id" {}
variable "private-subnet-0-id" {}
variable "private-subnet-1-id" {}
variable "max-size" {}
variable "min-size" {}
variable "desired-capacity" {}
variable "colour" {}
variable "environment" {}
variable "orchestration" {}
variable "createdby" {}
variable "image-id" {}
variable "instance-type" {}
variable "key-name" {}
variable "cert-arn" {}
variable "hosted-zone-name" {}
variable "hosted-zone-id" {}
variable "set-identifier" {}
variable "weight" {}
variable "ttl" {}
variable "tomcat-version" {}

#-------------------------------------------------------------------------------
# Defines Security Groups for ALBs and Webservers
#-------------------------------------------------------------------------------
resource "aws_security_group" "alb-sg" {
  name        = "alb-${var.colour}-sg"
  description = "Enable HTTP and HTTPS access via ports 80 and 443"
  vpc_id      = var.vpc-id

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
    Name          = "alb-${var.colour}-sg"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

resource "aws_security_group" "webservers-sg" {
  name        = "webservers-${var.colour}-sg"
  description = "Enable HTTP and HTTPS access via ports 80 and 443"
  vpc_id      = var.vpc-id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name          = "webservers-${var.colour}-sg"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

#-------------------------------------------------------------------------------
# Defines Role, Policy and Profile for Webservers
#-------------------------------------------------------------------------------
resource "aws_iam_role" "webservers-role" {
  name        = "webservers-role"
  description = "Role for Webservers. Needs to get artifact from S3 bucket"
  path        = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  tags = {
    Name          = "webservers-role"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}
resource "aws_iam_role_policy" "webservers-policy" {
  name   = "webservers-policy"
  role   = aws_iam_role.webservers-role.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "webservers-profile" {
  name = "webservers-profile"
  role = aws_iam_role.webservers-role.name
}

#-------------------------------------------------------------------------------
# Defines App Load Balanser and Target Group
#-------------------------------------------------------------------------------
resource "aws_lb" "alb" {
  name               = "${var.environment}-${var.colour}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb-sg.id]
  subnets         = [var.public-subnet-0-id, var.public-subnet-1-id]
  tags = {
    Name          = "${var.environment}-${var.colour}-alb"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

resource "aws_lb_target_group" "webservers-tg" {
  name        = "${var.environment}-${var.colour}-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc-id

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
    Name          = "${var.environment}-${var.colour}-tg"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

#-------------------------------------------------------------------------------
# Defines Listeners< Listener Rules and Record Sets
#-------------------------------------------------------------------------------
resource "aws_lb_listener" "http-listener" {
  load_balancer_arn = aws_lb.alb.arn
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

resource "aws_lb_listener" "https-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert-arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webservers-tg.arn
  }
}

resource "aws_lb_listener_rule" "webservers-listener-rule" {
  listener_arn = aws_lb_listener.https-listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webservers-tg.arn
  }
  condition {
    host_header {
      values = ["www.${var.hosted-zone-name}"]
    }
  }
}

resource "aws_route53_record" "main" {
  zone_id = var.hosted-zone-id
  name    = "${var.hosted-zone-name}."
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
  weighted_routing_policy {
    weight = var.weight
  }
  set_identifier = var.set-identifier
}

resource "aws_route53_record" "www" {
  zone_id = var.hosted-zone-id
  name    = "www"
  type    = "CNAME"
  ttl     = var.ttl

  weighted_routing_policy {
    weight = var.weight
  }
  set_identifier = var.set-identifier
  records        = [aws_lb.alb.dns_name]
}

#-------------------------------------------------------------------------------
# Defines Launch Configuration and ASG for Webservers
#-------------------------------------------------------------------------------
resource "aws_launch_configuration" "webservers-lc" {
  image_id                    = var.image-id
  instance_type               = var.instance-type
  associate_public_ip_address = true
  key_name                    = var.key-name
  iam_instance_profile        = aws_iam_instance_profile.webservers-profile.name
  security_groups             = [aws_security_group.webservers-sg.id]
  user_data                   = data.template_file.webserversUserData.rendered
}
data "template_file" "webserversUserData" {
  template = file("${path.module}/webserversUserData.sh")
  vars = {
    tomcat_version = var.tomcat-version
  }
}

resource "aws_autoscaling_group" "webservers-asg" {
  name                      = "${var.environment}-webservers-${var.colour}-asg"
  max_size                  = var.max-size
  min_size                  = var.min-size
  desired_capacity          = var.desired-capacity
  health_check_grace_period = 180
  health_check_type         = "ELB"

  launch_configuration = aws_launch_configuration.webservers-lc.id
  vpc_zone_identifier  = [var.private-subnet-0-id, var.private-subnet-1-id]

  target_group_arns = [aws_lb_target_group.webservers-tg.arn]
  tags = [
    {
      key                 = "Name"
      value               = "${var.environment}-webservers-${var.colour}-asg"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Orchestration"
      value               = var.orchestration
      propagate_at_launch = true
    },
    {
      key                 = "CreatedBy"
      value               = var.createdby
      propagate_at_launch = true
    }
  ]
}
