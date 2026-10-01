provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "ubuntu_ami" {
  name = var.ami_id
}

# =========================================================
# APPLICATION LOAD BALANCER & TARGET GROUP
# =========================================================

resource "aws_lb" "publico" {
  name               = "ALB-Publico"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.public_subnet_1_id, var.public_subnet_2_id]
  security_groups    = [var.alb_security_group_id]

  tags = {
    Name        = "ALB-Publico"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}

resource "aws_lb_target_group" "web_servers" {
  name     = "TG-WebServers"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/"
    interval = 30
  }

  tags = {
    Name    = "TG-WebServers"
    Project = "Projeto-Extensao"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.publico.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_servers.arn
  }
}

# =========================================================
# WEB SERVERS (Ubuntu 24.04 + Docker + Apache2)
# =========================================================

resource "aws_instance" "web_server_01" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_1_id
  vpc_security_group_ids = [var.web_server_security_group_id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y docker.io apache2
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Web-Server 01 (us-east-1a) - Ubuntu 24.04</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name        = "Web-Server 01"
    Role        = "Frontend-WebServer"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}

resource "aws_instance" "web_server_02" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_2_id
  vpc_security_group_ids = [var.web_server_security_group_id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y docker.io apache2
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Web-Server 02 (us-east-1b) - Ubuntu 24.04</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name        = "Web-Server 02"
    Role        = "Frontend-WebServer"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}

resource "aws_lb_target_group_attachment" "web_server_01" {
  target_group_arn = aws_lb_target_group.web_servers.arn
  target_id        = aws_instance.web_server_01.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server_02" {
  target_group_arn = aws_lb_target_group.web_servers.arn
  target_id        = aws_instance.web_server_02.id
  port             = 80
}

# =========================================================
# BACKEND SERVERS (Ubuntu 24.04 + Docker + OpenJDK 17)
# =========================================================

resource "aws_instance" "backend_01" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.private_subnet_1_id
  vpc_security_group_ids = [var.backend_security_group_id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y docker.io openjdk-17-jdk-headless
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
  EOF

  tags = {
    Name        = "Back-End 01 (us-east-1a)"
    Role        = "Backend"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}

resource "aws_instance" "backend_02" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.private_subnet_2_id
  vpc_security_group_ids = [var.backend_security_group_id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y docker.io openjdk-17-jdk-headless
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
  EOF

  tags = {
    Name        = "Back-End 02 (us-east-1b)"
    Role        = "Backend"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}
