provider "aws" {
  region = var.aws_region

  s3_use_path_style = true
}

# =========================================================
# S3 - BACKUP
# =========================================================

resource "aws_s3_bucket" "backup" {
  bucket = "sax-backup-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
  object_lock_enabled = false

  tags = {
    Name = "sax-s3-backup"
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket                  = aws_s3_bucket.backup.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================================================
# S3 - DATALAKE BRONZE
# =========================================================

resource "aws_s3_bucket" "bronze" {
  bucket              = "sax-bronze-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
  object_lock_enabled = false

  tags = {
    Name = "sax-s3-bronze"
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
  bucket              = "sax-silver-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
  object_lock_enabled = false

  tags = {
    Name = "sax-s3-silver"
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
  bucket              = "sax-gold-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
  object_lock_enabled = false

  tags = {
    Name = "sax-s3-gold"
  }
}

resource "aws_s3_bucket_public_access_block" "gold" {
  bucket                  = aws_s3_bucket.gold.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
