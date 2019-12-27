#-------------------------------------------------------------------------------
# To create resources run:
# terraform apply -target=module.webEC2
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Defines Webservers Security Group
#-------------------------------------------------------------------------------
resource "aws_security_group" "webserversSecurityGroup" {
  name        = "webserversSG"
  description = "Enable SSH access via port 22 and port 8080"
  vpc_id      = var.vpcId

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
    Name          = "webserversSG"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

#-------------------------------------------------------------------------------
# Defines Role, Policy and Profile for Webservers
#-------------------------------------------------------------------------------
resource "aws_iam_role" "webserversRole" {
  name        = "webserversRole"
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
    Name          = "webserversRole"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}
resource "aws_iam_role_policy" "webserversPolicy" {
  name   = "BastionPolicy"
  role   = aws_iam_role.webserversRole.name
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
resource "aws_iam_instance_profile" "webserversProfile" {
  name = "webserversProfile"
  role = aws_iam_role.webserversRole.name
}

#-------------------------------------------------------------------------------
# Defines Webservers Target Group and Listener Rule
#-------------------------------------------------------------------------------
resource "aws_lb_target_group" "webserversTG" {
  name        = "webserversTG"
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
    Name          = "webserversTG"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

resource "aws_lb_listener_rule" "webserversListenerRule" {
  listener_arn = var.httpsListenerArn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserversTG.arn
  }
  condition {
    host_header {
      values = ["www.${var.hostedZoneName}"]
    }
  }
}

#-------------------------------------------------------------------------------
# Defines Record Sets
#-------------------------------------------------------------------------------
# resource "aws_route53_record" "main" {
#   zone_id = "${var.hostedZoneName}."
#   name    = "${var.hostedZoneName}."
#   type    = "A"
#   ttl     = "300"
#   records = ["${aws_eip.lb.public_ip}"]
# }
resource "aws_route53_record" "www" {
  zone_id = "${var.hostedZoneName}."
  name    = "www.${var.hostedZoneName}."
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_eip.lb.public_ip}"]
}

#-------------------------------------------------------------------------------
# Defines Launch Configuration for Webservers
#-------------------------------------------------------------------------------
resource "aws_launch_configuration" "webserversLaunchConfig" {
  image_id                    = var.imageId
  instance_type               = var.instanceType
  associate_public_ip_address = true
  key_name                    = var.keyName
  iam_instance_profile        = aws_iam_instance_profile.webserversProfile.name
  security_groups             = [aws_security_group.webserversSecurityGroup.id]
  user_data                   = data.template_file.webserversUserData.rendered

}
data "template_file" "bastionUserData" {
  template = file("${path.module}/webserversUserData.sh")
  vars = {
    region = var.region,
    eipId  = aws_eip.BastionEIP.id
  }
}

#-------------------------------------------------------------------------------
# Defines Auto Scaling Group for Webservers
#-------------------------------------------------------------------------------
resource "aws_autoscaling_group" "webserversASG" {
  vpc_zone_identifier  = [var.privateSubnet0id, var.privateSubnet1id]
  launch_configuration = aws_launch_configuration.webserversLaunchConfig.id
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  tags = [
    {
      key                 = "Name"
      value               = "webserversASG"
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
    },
  ]
}
