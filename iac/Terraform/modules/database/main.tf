# =========================================================
# DATABASE INSTANCE (EC2 - Ubuntu 26.04 com MySQL nativo)
# =========================================================

resource "aws_instance" "database" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.database_subnet_id
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

    # Instalacao do MySQL Server nativo
    apt-get install -y mysql-server

    # Permitir conexoes de rede privada (bind 0.0.0.0)
    sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
    sed -i 's/^mysqlx-bind-address\s*=.*/mysqlx-bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf 2>/dev/null || true

    # Reiniciar e habilitar o servico MySQL
    systemctl restart mysql
    systemctl enable mysql
  EOF

  tags = {
    Name        = "EC2-Database-MySQL"
    Role        = "Database"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}
