output "web_server_public_ips" {
  description = "Public IP addresses of the web server instances"
  value       = aws_instance.web_server[*].public_ip
}

output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}
