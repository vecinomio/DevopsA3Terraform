# Creates Custom VPC in AWS with public and private subnets
#-------------------------------------------------------------------------------
# To create all infrastructure run:
# terraform apply
#-------------------------------------------------------------------------------
provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  orchestration = var.orchestration
  createdby     = var.createdby
  environment   = var.environment
  region        = var.region
  AZDefiners    = var.AZDefiners
  vpcCIDR       = var.vpcCIDR
}

module "alb" {
  source = "./modules/alb"

  orchestration   = var.orchestration
  createdby       = var.createdby
  environment     = var.environment
  hostedZoneName  = var.hostedZoneName
  certArn         = var.certARN
  vpcId           = module.vpc.vpcId
  publicSubnet0id = module.vpc.PublicSubnet0id
  publicSubnet1id = module.vpc.PublicSubnet1id
}

module "bastion" {
  source = "./modules/bastion"

  orchestration   = var.orchestration
  createdby       = var.createdby
  environment     = var.environment
  region          = var.region
  keyName         = var.keyName
  hostedZoneName  = var.hostedZoneName
  hostedZoneId    = var.hostedZoneId
  vpcId           = module.vpc.vpcId
  publicSubnet0id = module.vpc.PublicSubnet0id
  publicSubnet1id = module.vpc.PublicSubnet1id
}

module "webservers-blue-asg" {
  source = "./modules/webservers-asg"

  env              = "live"
  color            = "blue"
  image-id         = "ami-00068cd7555f543d5"
  instance-type    = "t2.micro"
  key-name         = "devopsa3"
  user-data        = "user-data-1"
  set-identifier   = "api-blue"
  ttl              = 60
  weight           = 50
  max-size         = 2
  desired-capacity = 1
  min-size         = 1
  vpc-id           = module.vpc.vpcId
  publicSubnet0id  = module.vpc.PublicSubnet0id
  publicSubnet1id  = module.vpc.PublicSubnet1id
}

module "webservers-green-asg" {
  source           = "./modules/webservers-asg"
  env              = "live"
  color            = "green"
  image-id         = "ami-00068cd7555f543d5"
  instance-type    = "t2.micro"
  key-name         = "devopsa3"
  user-data        = "user-data-2"
  set-identifier   = "api-green"
  ttl              = 60
  weight           = 50
  max-size         = 2
  desired-capacity = 1
  min-size         = 1
  vpc-id           = module.vpc.vpcId
  publicSubnet0id  = module.vpc.PublicSubnet0id
  publicSubnet1id  = module.vpc.PublicSubnet1id
}

# module "webEC2" {
#   source = "./modules/webEC2"
#
#   orchestration           = var.orchestration
#   createdby               = var.createdby
#   environment             = var.environment
#   region                  = var.region
#   keyName                 = var.keyName
#   hostedZoneName          = var.hostedZoneName
#   hostedZoneId            = var.hostedZoneId
#   tomcatVersion           = var.tomcatVersion
#   vpcId                   = module.vpc.vpcId
#   privateSubnet0id        = module.vpc.PrivateSubnet0id
#   privateSubnet1id        = module.vpc.PrivateSubnet1id
#   httpsListenerArn        = module.alb.httpsListenerArn
#   albDnsName              = module.alb.albDnsName
#   albArnSuffix            = module.alb.albArnSuffix
#   lbCanonicalHostedZoneId = module.alb.lbCanonicalHostedZoneId
# }
