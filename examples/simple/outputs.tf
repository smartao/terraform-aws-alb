output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "The ARN of the load balancer."
  value       = module.alb.alb_arn
}
