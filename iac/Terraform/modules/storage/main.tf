# =========================================================
# S3 - LOGS
# =========================================================

resource "aws_s3_bucket" "logs" {
  bucket = "sax-logs-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"

  tags = {
    Name        = "S3-Registros-de-Logs"
    Purpose     = "Logs"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================================================
# S3 - DATALAKE BRONZE
# =========================================================

resource "aws_s3_bucket" "bronze" {
  bucket = "sax-bronze-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"

  tags = {
    Name        = "S3-DataLake-Bronze"
    Purpose     = "DataLake-Bronze"
    Layer       = "Bronze"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_public_access_block" "bronze" {
  bucket                  = aws_s3_bucket.bronze.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================================================
# S3 - DATALAKE SILVER
# =========================================================

resource "aws_s3_bucket" "silver" {
  bucket = "sax-silver-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"

  tags = {
    Name        = "S3-DataLake-Silver"
    Purpose     = "DataLake-Silver"
    Layer       = "Silver"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_public_access_block" "silver" {
  bucket                  = aws_s3_bucket.silver.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================================================
# S3 - DATALAKE GOLD
# =========================================================

resource "aws_s3_bucket" "gold" {
  bucket = "sax-gold-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"

  tags = {
    Name        = "S3-DataLake-Gold"
    Purpose     = "DataLake-Gold"
    Layer       = "Gold"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_public_access_block" "gold" {
  bucket                  = aws_s3_bucket.gold.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
