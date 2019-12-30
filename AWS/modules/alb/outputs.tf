output "httpsListenerArn" {
  description = "The HTTPS Listener ARN"
  value       = aws_lb_listener.httpsListener.arn
}
output "albDnsName" {
  description = "The original DNS Name of the ALB"
  value       = aws_lb.appLB.dns_name
}
output "lbCanonicalHostedZoneId" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.appLB.zone_id
}
output "albArnSuffix" {
  description = "The ARN suffix of the ALB ARN"
  value       = aws_lb.appLB.arn_suffix
}
