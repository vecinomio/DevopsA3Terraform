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
  description = "The name of the exsisting hosted zone"
  type        = string
  default     = "miit.pp.ua"
}
variable "hostedZoneId" {
  description = "An ID of the exsisting hosted zone"
  type        = string
  default     = "Z3054OS2WUR0EL"
}

variable "certARN" {
  description = "An ARN of the AWS public certificate"
  type        = string
  default     = "arn:aws:acm:us-east-1:899333571677:certificate/64095605-9aab-4da9-bb1e-daecdc0051de"
}

variable "tomcatVersion" {
  description = "The desired version of Tomcat Web Server"
  type        = string
  default     = "9.0.30"
}
