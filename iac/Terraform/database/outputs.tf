output "log_bucket_name" {
  description = "Nome do bucket utilizado para armazenamento de logs"
  value       = aws_s3_bucket.logs.id
}

output "log_bucket_arn" {
  description = "ARN do bucket de logs"
  value       = aws_s3_bucket.logs.arn
}

output "data_lake_bucket_name" {
  description = "Nome do bucket utilizado como Data Lake"
  value       = aws_s3_bucket.data_lake.id
}

output "data_lake_bucket_arn" {
  description = "ARN do bucket Data Lake"
  value       = aws_s3_bucket.data_lake.arn
}

output "rds_instance_identifier" {
  description = "Identificador da instancia RDS"
  value       = aws_db_instance.principal.identifier
}

output "rds_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = aws_db_instance.principal.address
}

output "rds_port" {
  description = "Porta utilizada pelo RDS"
  value       = aws_db_instance.principal.port
}
