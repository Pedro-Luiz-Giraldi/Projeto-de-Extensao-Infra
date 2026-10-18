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
