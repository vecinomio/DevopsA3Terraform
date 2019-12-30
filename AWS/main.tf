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
  vpcId           = module.vpc.vpcId
  publicSubnet0id = module.vpc.PublicSubnet0id
  publicSubnet1id = module.vpc.PublicSubnet1id
}

module "webEC2" {
  source = "./modules/webEC2"

  orchestration           = var.orchestration
  createdby               = var.createdby
  environment             = var.environment
  region                  = var.region
  keyName                 = var.keyName
  hostedZoneName          = var.hostedZoneName
  hostedZoneId            = var.hostedZoneId
  tomcatVersion           = var.tomcatVersion
  vpcId                   = module.vpc.vpcId
  privateSubnet0id        = module.vpc.PrivateSubnet0id
  privateSubnet1id        = module.vpc.PrivateSubnet1id
  httpsListenerArn        = module.alb.httpsListenerArn
  albDnsName              = module.alb.albDnsName
  albArnSuffix            = module.alb.albArnSuffix
  lbCanonicalHostedZoneId = module.alb.lbCanonicalHostedZoneId
}
