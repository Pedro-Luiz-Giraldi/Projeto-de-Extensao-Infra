output "load_balancer_dns" {
  description = "URL publica do Application Load Balancer"
  value       = module.application.load_balancer_dns
}

output "web_server_01_id" {
  description = "ID da instancia Web Server 01"
  value       = module.application.web_server_01_id
}

output "web_server_02_id" {
  description = "ID da instancia Web Server 02"
  value       = module.application.web_server_02_id
}

output "backend_01_id" {
  description = "ID da instancia Backend 01"
  value       = module.application.backend_01_id
}

output "backend_02_id" {
  description = "ID da instancia Backend 02"
  value       = module.application.backend_02_id
}

output "database_instance_id" {
  description = "ID da instancia EC2 do banco de dados MySQL"
  value       = module.database.database_instance_id
}

output "database_private_ip" {
  description = "IP privado da instancia de banco de dados MySQL"
  value       = module.database.database_private_ip
}


output "log_bucket_name" {
  description = "Nome do bucket utilizado para armazenamento de logs"
  value       = module.storage.log_bucket_name
}

output "log_bucket_arn" {
  description = "ARN do bucket de logs"
  value       = module.storage.log_bucket_arn
}

output "bronze_bucket_name" {
  description = "Nome do bucket DataLake Bronze"
  value       = module.storage.bronze_bucket_name
}

output "bronze_bucket_arn" {
  description = "ARN do bucket DataLake Bronze"
  value       = module.storage.bronze_bucket_arn
}

output "silver_bucket_name" {
  description = "Nome do bucket DataLake Silver"
  value       = module.storage.silver_bucket_name
}

output "silver_bucket_arn" {
  description = "ARN do bucket DataLake Silver"
  value       = module.storage.silver_bucket_arn
}

output "gold_bucket_name" {
  description = "Nome do bucket DataLake Gold"
  value       = module.storage.gold_bucket_name
}

output "gold_bucket_arn" {
  description = "ARN do bucket DataLake Gold"
  value       = module.storage.gold_bucket_arn
}
