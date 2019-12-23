# Creates Custom VPC in GCP with public and private subnets
provider "google" {
  credentials = file("~/.ssh/devopsa3-262611-173f8b71c1b0.json")
  project     = var.project-id
  region      = var.region
}


module "vpc" {
  source = "./modules/vpc"

  region = var.region
}

# module "bastion" {
#   source = "./modules/bastion"
#
#   region = var.region
# }
