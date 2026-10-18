output "database_instance_id" {
  description = "ID da instancia EC2 do banco de dados MySQL"
  value       = aws_instance.database.id
}

output "database_private_ip" {
  description = "IP privado da instancia de banco de dados MySQL"
  value       = aws_instance.database.private_ip
}

output "database_port" {
  description = "Porta utilizada pelo MySQL"
  value       = "3306"
}
