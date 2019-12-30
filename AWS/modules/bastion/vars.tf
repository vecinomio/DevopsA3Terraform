variable "orchestration" {}
variable "createdby" {}
variable "environment" {}
variable "region" {}
variable "vpcId" {}
variable "publicSubnet0id" {}
variable "publicSubnet1id" {}
variable "keyName" {}
variable "hostedZoneName" {}
variable "hostedZoneId" {}
variable "imageId" {
  description = "Amazon Linux 2"
  type        = string
  default     = "ami-00068cd7555f543d5"
}
variable "instanceType" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}
