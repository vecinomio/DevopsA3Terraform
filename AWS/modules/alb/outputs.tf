output "httpsListenerArn" {
  description = "The HTTPS Listener ARN"
  value       = aws_lb_listener.httpsListener.arn
}
output "albDnsName" {
  description = "The original DNS Name of the ALB"
  value       = aws_lb_listener.appLB.dns_name
}
output "canonicalHostedZoneId" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb_listener.appLB.zone_id
}
