output "load_balancer_dns" {
  description = "URL publica do Application Load Balancer"
  value       = "http://${aws_lb.publico.dns_name}"
}

output "web_server_01_id" {
  description = "ID da instancia Web Server 01"
  value       = aws_instance.web_server_01.id
}

output "web_server_02_id" {
  description = "ID da instancia Web Server 02"
  value       = aws_instance.web_server_02.id
}

output "backend_01_id" {
  description = "ID da instancia Backend 01"
  value       = aws_instance.backend_01.id
}

output "backend_02_id" {
  description = "ID da instancia Backend 02"
  value       = aws_instance.backend_02.id
}
