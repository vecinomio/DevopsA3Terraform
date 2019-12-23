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

module "bastion" {
  source = "./modules/bastion"

  orchestration   = var.orchestration
  createdby       = var.createdby
  environment     = var.environment
  region          = var.region
  keyName         = var.keyName
  vpcId           = module.vpc.vpcId
  igwId           = module.vpc.igwId
  publicSubnet0id = module.vpc.PublicSubnet0id
  publicSubnet1id = module.vpc.PublicSubnet1id
}
