variable "vpc-id" {}
variable "publicSubnet0id" {}
variable "publicSubnet1id" {}
variable "max-size" {}
variable "min-size" {}
variable "desired-capacity" {}
variable "env" {}
variable "color" {}
variable "image-id" {}
variable "instance-type" {}
variable "key-name" {}
variable "user-data" {}
variable "set-identifier" {}
variable "weight" {}
variable "ttl" {}

#-------------------------------------------------------------------------------
# Defines Security Groups for ALBs and Webservers
#-------------------------------------------------------------------------------
resource "aws_security_group" "alb-sg" {
  name        = "alb-${var.color}-sg"
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
    Name = "alb-${var.color}-sg"
  }
}

resource "aws_security_group" "webservers-sg" {
  name        = "webservers-${var.color}-sg"
  description = "Enable HTTP and HTTPS access via ports 80 and 443"
  vpc_id      = var.vpc-id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "webservers-${var.color}-sg"
  }
}

#-------------------------------------------------------------------------------
# Defines App Load Balanser, Target Group, Listeners and Record Sets
#-------------------------------------------------------------------------------
resource "aws_alb" "collect-alb" {
  name               = "${var.env}-collect-${var.color}-lb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb-sg.id]
  subnets         = [var.publicSubnet0id, var.publicSubnet1id]
  tags = {
    Name = "${var.env}-collect-${var.color}-lb"
  }
}

resource "aws_alb_target_group" "collect-alb-tg" {
  name     = "${var.env}-collect-${var.color}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc-id

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
    Name = "${var.env}-collect-${var.color}-tg"
  }
}

resource "aws_alb_listener" "httpListener" {
  load_balancer_arn = aws_alb.collect-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.collect-alb-tg.arn
  }
}

resource "aws_route53_record" "web" {
  zone_id = "Z3054OS2WUR0EL"
  name    = "web"
  type    = "CNAME"
  ttl     = var.ttl

  weighted_routing_policy {
    weight = var.weight
  }
  set_identifier = var.set-identifier
  records        = [aws_alb.collect-alb.dns_name]
}

#-------------------------------------------------------------------------------
# Defines Launch Configuration and ASG for Webservers
#-------------------------------------------------------------------------------
resource "aws_launch_configuration" "collect-lc" {
  image_id                    = var.image-id
  instance_type               = var.instance-type
  associate_public_ip_address = true
  key_name                    = var.key-name
  # iam_instance_profile        = aws_iam_instance_profile.webserversProfile.name
  security_groups = [aws_security_group.webservers-sg.id]
  user_data       = data.template_file.user-data.rendered

}
data "template_file" "user-data" {
  template = file("${path.module}/${var.user-data}.sh")
}

resource "aws_autoscaling_group" "collect-asg" {
  name                      = "${var.env}-collect-${var.color}-asg"
  max_size                  = var.max-size
  min_size                  = var.min-size
  desired_capacity          = var.desired-capacity
  health_check_grace_period = 180
  health_check_type         = "ELB"

  launch_configuration = aws_launch_configuration.collect-lc.id
  vpc_zone_identifier  = [var.publicSubnet0id, var.publicSubnet1id]

  target_group_arns = [aws_alb_target_group.collect-alb-tg.arn]
  tags = [
    {
      key                 = "Name"
      value               = "${var.env}-collect-${var.color}-asg"
      propagate_at_launch = true
    }
  ]
}
