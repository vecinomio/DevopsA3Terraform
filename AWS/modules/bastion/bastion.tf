#-------------------------------------------------------------------------------
# Defines Bastion Security Group
#-------------------------------------------------------------------------------
resource "aws_security_group" "BastionSecurityGroup" {
  name        = "BastionSG"
  description = "Enable SSH access via port 22"
  vpc_id      = var.vpcId

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name          = "BastionSG"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

#-------------------------------------------------------------------------------
# Defines Elastic IP for Bastion Host
#-------------------------------------------------------------------------------
resource "aws_eip" "BastionEIP" {
  vpc = true
  tags = {
    Name          = "BastionEIP"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
  depends_on = [var.igwId]
}

#-------------------------------------------------------------------------------
# Defines Role, Policy and Profile for Bastion Host
#-------------------------------------------------------------------------------
resource "aws_iam_role" "BastionRole" {
  name        = "BastionRole"
  description = "Role for Bastion-host. Needs to associate EIP"
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
    Name          = "BastionRole"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}
resource "aws_iam_role_policy" "BastionPolicy" {
  name   = "BastionPolicy"
  role   = aws_iam_role.BastionRole.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AssociateAddress"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "BastionProfile" {
  name = "BastionProfile"
  role = aws_iam_role.BastionRole.name
}

#-------------------------------------------------------------------------------
# Defines Launch Configuration for Bastion Host
#-------------------------------------------------------------------------------
resource "aws_launch_configuration" "BastionLaunchConfig" {
  image_id                    = var.imageId
  instance_type               = var.instanceType
  associate_public_ip_address = true
  key_name                    = var.keyName
  iam_instance_profile        = aws_iam_instance_profile.BastionProfile.name
  security_groups             = [aws_security_group.BastionSecurityGroup.id]
  user_data                   = data.template_file.bastionUserData.rendered

}
data "template_file" "bastionUserData" {
  template = file("${path.module}/bastionUserData.sh")
  vars = {
    region = var.region,
    eipId  = aws_eip.BastionEIP.id
  }
}

#-------------------------------------------------------------------------------
# Defines Auto Scaling Group for Bastion Host
#-------------------------------------------------------------------------------
resource "aws_autoscaling_group" "BastionASG" {
  vpc_zone_identifier  = [var.publicSubnet0id, var.publicSubnet1id]
  launch_configuration = aws_launch_configuration.BastionLaunchConfig.id
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  tags = [
    {
      key                 = "Name"
      value               = "BastionASG"
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
