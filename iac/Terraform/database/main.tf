provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "logs" {
  tags = {
    Name    = "S3-Registros-de-Logs"
    Purpose = "Logs"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "data_lake" {
  tags = {
    Name    = "S3-DataLake"
    Purpose = "DataLake"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket                  = aws_s3_bucket.data_lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_db_subnet_group" "rds" {
  description = "Subnets privadas utilizadas pelo RDS"
  subnet_ids  = [var.private_subnet_1_id, var.private_subnet_2_id]

  tags = {
    Name = "RDS-SubnetGroup"
  }
}

resource "aws_db_instance" "principal" {
  identifier              = "banco-principal"
  engine                  = "mysql"
  engine_version          = "8.4"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp3"
  storage_encrypted       = true
  db_name                 = "appdb"
  username                = var.db_username
  password                = var.db_password
  vpc_security_group_ids  = [var.database_security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  publicly_accessible     = false
  backup_retention_period = 7
  multi_az                = false
  deletion_protection     = false

  tags = {
    Name = "RDS-Banco-Principal"
  }
}
