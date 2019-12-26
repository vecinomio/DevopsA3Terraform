variable "orchestration" {
  description = "Kind of the orchestration platform"
  type        = string
  default     = "Terraform12"
}

variable "createdby" {
  description = "Created by"
  type        = string
  default     = "imaki"
}

variable "environment" {
  description = "Environment for the resources"
  type        = string
  default     = "Dev"
}

variable "region" {
  description = "Desired Region"
  type        = string
  default     = "us-east-1"
}

variable "keyName" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instance"
  type        = string
  default     = "devopsa3"
}

variable "AZDefiners" {
  description = "list of letters - identifiers Availability Zones"
  type        = list(string)
  default     = ["a", "b"]
}

variable "vpcCIDR" {
  description = "CIDR for the whole VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "hostedZoneName" {
  description = "The name pf the hosted zone"
  type        = string
  default     = "miit.pp.ua"
}

variable "certARN" {
  description = "An ARN of the AWS public certificate"
  type        = string
  default     = "arn:aws:acm:us-east-1:899333571677:certificate/9a9bfd74-049a-4108-a484-175da35e0587"
}
