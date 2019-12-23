output "vpcId" {
  description = "An ID of the Custom VPC"
  value       = aws_vpc.vpcA3.id
}

# output "VpcRegion" {
#   description = "Region, where VPC was deployed"
#   value       = aws_region
# }

output "PublicSubnet0id" {
  description = "Subnet Id of public subnet 0"
  value       = aws_subnet.PublicSubnet0.id
}

output "PublicSubnet1id" {
  description = "Subnet Id of public subnet 1"
  value       = aws_subnet.PublicSubnet1.id
}

output "PrivateSubnet0id" {
  description = "Subnet Id of private subnet 0"
  value       = aws_subnet.PrivateSubnet0.id
}

output "PrivateSubnet1id" {
  description = "Subnet Id of private subnet 1"
  value       = aws_subnet.PrivateSubnet1.id
}

output "igwId" {
  description = "An ID of the Internet Gateway"
  value       = aws_internet_gateway.IGW.id
}
