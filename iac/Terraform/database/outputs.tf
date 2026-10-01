output "log_bucket_name" {
  description = "Nome do bucket utilizado para armazenamento de logs"
  value       = aws_s3_bucket.logs.id
}

output "log_bucket_arn" {
  description = "ARN do bucket de logs"
  value       = aws_s3_bucket.logs.arn
}

output "bronze_bucket_name" {
  description = "Nome do bucket DataLake Bronze"
  value       = aws_s3_bucket.bronze.id
}

output "bronze_bucket_arn" {
  description = "ARN do bucket DataLake Bronze"
  value       = aws_s3_bucket.bronze.arn
}

output "silver_bucket_name" {
  description = "Nome do bucket DataLake Silver"
  value       = aws_s3_bucket.silver.id
}

output "silver_bucket_arn" {
  description = "ARN do bucket DataLake Silver"
  value       = aws_s3_bucket.silver.arn
}

output "gold_bucket_name" {
  description = "Nome do bucket DataLake Gold"
  value       = aws_s3_bucket.gold.id
}

output "gold_bucket_arn" {
  description = "ARN do bucket DataLake Gold"
  value       = aws_s3_bucket.gold.arn
}

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
