/* output "public_ip" {
  description = "The public IP address of the web server instance"
  sensitive   = false 
  value       = aws_instance.example.public_ip
  # depends_on is optional 
} */ 

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.example.dns_name
}
