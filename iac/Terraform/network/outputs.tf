output "vpc_id" {
  description = "ID da VPC principal"
  value       = aws_vpc.principal.id
}

output "public_subnet_1_id" {
  description = "ID da subnet publica us-east-1a"
  value       = aws_subnet.publica_1.id
}

output "public_subnet_2_id" {
  description = "ID da subnet publica us-east-1b"
  value       = aws_subnet.publica_2.id
}

output "private_subnet_1_id" {
  description = "ID da subnet privada us-east-1a"
  value       = aws_subnet.privada_1.id
}

output "private_subnet_2_id" {
  description = "ID da subnet privada us-east-1b"
  value       = aws_subnet.privada_2.id
}

output "alb_security_group_id" {
  description = "Security Group do Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "web_server_security_group_id" {
  description = "Security Group dos servidores Web"
  value       = aws_security_group.web_server.id
}

output "backend_security_group_id" {
  description = "Security Group dos servidores Backend"
  value       = aws_security_group.backend.id
}

output "database_security_group_id" {
  description = "Security Group do Servidor de Banco de Dados MySQL"
  value       = aws_security_group.database.id
}
