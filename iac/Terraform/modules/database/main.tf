# =========================================================
# DATABASE INSTANCE (EC2 - Ubuntu 26.04 with native MySQL)
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

    # Update system packages
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get upgrade -y

    # Install native MySQL Server
    apt-get install -y mysql-server

    # Allow network connections (bind 0.0.0.0)
    sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
    sed -i 's/^mysqlx-bind-address\s*=.*/mysqlx-bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf 2>/dev/null || true

    # Restart and enable MySQL service
    systemctl restart mysql
    systemctl enable mysql
  EOF

  tags = {
    Name = "sax-ec2-database"
  }
}
