# Creates Custom VPC in AWS with public and private subnets
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
