provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "ubuntu_ami" {
  name = var.ami_id
}

# =========================================================
# S3 - LOGS
# =========================================================

resource "aws_s3_bucket" "logs" {
  tags = {
    Name        = "S3-Registros-de-Logs"
    Purpose     = "Logs"
    Project     = "Projeto-Extensao"
    Environment = "Production"
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

# =========================================================
# S3 - DATALAKE BRONZE
# =========================================================

resource "aws_s3_bucket" "bronze" {
  tags = {
    Name        = "S3-DataLake-Bronze"
    Purpose     = "DataLake-Bronze"
    Layer       = "Bronze"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bronze" {
  bucket = aws_s3_bucket.bronze.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bronze" {
  bucket                  = aws_s3_bucket.bronze.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bronze" {
  bucket = aws_s3_bucket.bronze.id

  versioning_configuration {
    status = "Enabled"
  }
}

# =========================================================
# S3 - DATALAKE SILVER
# =========================================================

resource "aws_s3_bucket" "silver" {
  tags = {
    Name        = "S3-DataLake-Silver"
    Purpose     = "DataLake-Silver"
    Layer       = "Silver"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "silver" {
  bucket = aws_s3_bucket.silver.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "silver" {
  bucket                  = aws_s3_bucket.silver.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "silver" {
  bucket = aws_s3_bucket.silver.id

  versioning_configuration {
    status = "Enabled"
  }
}

# =========================================================
# S3 - DATALAKE GOLD
# =========================================================

resource "aws_s3_bucket" "gold" {
  tags = {
    Name        = "S3-DataLake-Gold"
    Purpose     = "DataLake-Gold"
    Layer       = "Gold"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "gold" {
  bucket = aws_s3_bucket.gold.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "gold" {
  bucket                  = aws_s3_bucket.gold.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "gold" {
  bucket = aws_s3_bucket.gold.id

  versioning_configuration {
    status = "Enabled"
  }
}

# =========================================================
# DATABASE INSTANCE (EC2 - Ubuntu 24.04 com Docker + MySQL nativo)
# =========================================================

resource "aws_instance" "database" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.private_subnet_1_id
  vpc_security_group_ids = [var.database_security_group_id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Atualizacao de pacotes do sistema
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get upgrade -y

    # Instalacao e inicializacao do Docker
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu

    # Instalacao do MySQL Server nativo
    apt-get install -y mysql-server

    # Permitir conexoes de rede privada (bind 0.0.0.0)
    sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
    sed -i 's/^mysqlx-bind-address\s*=.*/mysqlx-bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf 2>/dev/null || true

    # Reiniciar e habilitar o servico MySQL
    systemctl restart mysql
    systemctl enable mysql

    # Aguardar MySQL inicializar completamente
    until mysqladmin ping --silent; do
        sleep 2
    done

    # Configuracao de seguranca basica, criacao do banco e usuario da aplicacao
    mysql -u root <<SQL
    ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '${var.db_password}';
    CREATE DATABASE IF NOT EXISTS \`${var.db_name}\`;
    CREATE USER IF NOT EXISTS '${var.db_username}'@'%' IDENTIFIED BY '${var.db_password}';
    GRANT ALL PRIVILEGES ON \`${var.db_name}\`.* TO '${var.db_username}'@'%';
    FLUSH PRIVILEGES;
    SQL
  EOF

  tags = {
    Name        = "EC2-Database-MySQL"
    Role        = "Database"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}
