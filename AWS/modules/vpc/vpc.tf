#-------------------------------------------------------------------------------
# To create resources run:
# terraform apply -target=module.vpc
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Defines Custom VPC
#-------------------------------------------------------------------------------
resource "aws_vpc" "vpcA3" {
  cidr_block           = var.vpcCIDR
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name          = "VPC Public and Private with NAT"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

#-------------------------------------------------------------------------------
# Defines Public and Private Subnets for custom VPC
#-------------------------------------------------------------------------------
resource "aws_subnet" "PublicSubnet0" {
  vpc_id                  = aws_vpc.vpcA3.id
  cidr_block              = "172.16.0.0/24"
  availability_zone       = join("", [var.region, element(var.AZDefiners, 0)])
  map_public_ip_on_launch = true
  tags = {
    Name          = "PublicSubnet0"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}
resource "aws_subnet" "PublicSubnet1" {
  vpc_id                  = aws_vpc.vpcA3.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = join("", [var.region, element(var.AZDefiners, 1)])
  map_public_ip_on_launch = true
  tags = {
    Name          = "PublicSubnet1"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

resource "aws_subnet" "PrivateSubnet0" {
  vpc_id            = aws_vpc.vpcA3.id
  cidr_block        = "172.16.100.0/24"
  availability_zone = join("", [var.region, element(var.AZDefiners, 0)])
  tags = {
    Name          = "PrivateSubnet0"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}
resource "aws_subnet" "PrivateSubnet1" {
  vpc_id            = aws_vpc.vpcA3.id
  cidr_block        = "172.16.101.0/24"
  availability_zone = join("", [var.region, element(var.AZDefiners, 1)])
  tags = {
    Name          = "PrivateSubnet1"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

#-------------------------------------------------------------------------------
# Defines Internet Gateway
#-------------------------------------------------------------------------------
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.vpcA3.id
  tags = {
    Name          = "IGW"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

#-------------------------------------------------------------------------------
# Defines Public Route Table and it's associations
#-------------------------------------------------------------------------------
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.vpcA3.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name          = "PublicRT"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}
resource "aws_route_table_association" "Public0" {
  subnet_id      = aws_subnet.PublicSubnet0.id
  route_table_id = aws_route_table.PublicRouteTable.id
}
resource "aws_route_table_association" "Public1" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

#-------------------------------------------------------------------------------
# Defines Public Network ACL
#-------------------------------------------------------------------------------
resource "aws_network_acl" "PublicNetworkAcl" {
  vpc_id     = aws_vpc.vpcA3.id
  subnet_ids = [aws_subnet.PublicSubnet0.id, aws_subnet.PublicSubnet1.id]
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name          = "PublicNACL"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

#-------------------------------------------------------------------------------
# Defines Elastic IPs for NAT Gateways
#-------------------------------------------------------------------------------
resource "aws_eip" "ElasticIP0" {
  vpc = true
  tags = {
    Name          = "NatEIP0"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
  depends_on = [aws_internet_gateway.IGW]
}
resource "aws_eip" "ElasticIP1" {
  vpc = true
  tags = {
    Name          = "NatEIP1"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
  depends_on = [aws_internet_gateway.IGW]
}

#-------------------------------------------------------------------------------
# Defines Nat Gateways for 2 AZs
#-------------------------------------------------------------------------------
resource "aws_nat_gateway" "NatGateway0" {
  allocation_id = aws_eip.ElasticIP0.id
  subnet_id     = aws_subnet.PublicSubnet0.id
  tags = {
    Name          = "Nat0"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
  depends_on = [aws_internet_gateway.IGW]
}
resource "aws_nat_gateway" "NatGateway1" {
  allocation_id = aws_eip.ElasticIP1.id
  subnet_id     = aws_subnet.PublicSubnet1.id
  tags = {
    Name          = "Nat1"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
  depends_on = [aws_internet_gateway.IGW]
}

#-------------------------------------------------------------------------------
# Defines Private Route Tables and their associations
#-------------------------------------------------------------------------------
resource "aws_route_table" "PrivateRouteTable0" {
  vpc_id = aws_vpc.vpcA3.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NatGateway0.id
  }
  tags = {
    Name          = "PrivateRT0"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}
resource "aws_route_table" "PrivateRouteTable1" {
  vpc_id = aws_vpc.vpcA3.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NatGateway1.id
  }
  tags = {
    Name          = "PrivateRT1"
    Environment   = var.environment
    Orchestration = var.orchestration
    CreatedBy     = var.createdby
  }
}

resource "aws_route_table_association" "Private0" {
  subnet_id      = aws_subnet.PrivateSubnet0.id
  route_table_id = aws_route_table.PrivateRouteTable0.id
}
resource "aws_route_table_association" "Private1" {
  subnet_id      = aws_subnet.PrivateSubnet1.id
  route_table_id = aws_route_table.PrivateRouteTable1.id
}
