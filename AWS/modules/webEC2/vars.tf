variable "orchestration" {}
variable "createdby" {}
variable "environment" {}
variable "region" {}
variable "vpcId" {}
variable "keyName" {}
variable "hostedZoneName" {}
variable "hostedZoneId" {}
variable "tomcatVersion" {}
variable "privateSubnet0id" {}
variable "privateSubnet1id" {}
variable "httpsListenerArn" {}
variable "albDnsName" {}
variable "albArnSuffix" {}
variable "lbCanonicalHostedZoneId" {}
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
variable "name" {
  description = "The name for the related resources"
  type        = string
  default     = "webservers"
}
