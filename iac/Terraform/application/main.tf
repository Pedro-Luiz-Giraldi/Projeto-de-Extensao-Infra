provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = var.ami_id
}

resource "aws_lb" "publico" {
  name               = "ALB-Publico"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.public_subnet_1_id, var.public_subnet_2_id]
  security_groups    = [var.alb_security_group_id]

  tags = {
    Name = "ALB-Publico"
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

resource "aws_instance" "web_server_01" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_1_id
  vpc_security_group_ids = [var.web_server_security_group_id]
  user_data              = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Web-Server 01 (us-east-1a)</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "Web-Server 01"
  }
}

resource "aws_instance" "web_server_02" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_2_id
  vpc_security_group_ids = [var.web_server_security_group_id]
  user_data              = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Web-Server 02 (us-east-1b)</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "Web-Server 02"
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

resource "aws_instance" "backend_01" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_1_id
  vpc_security_group_ids = [var.backend_security_group_id]
  user_data              = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y java-17-amazon-corretto
  EOF

  tags = {
    Name = "Back-End 01 (us-east-1a)"
  }
}

resource "aws_instance" "backend_02" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_2_id
  vpc_security_group_ids = [var.backend_security_group_id]
  user_data              = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y java-17-amazon-corretto
  EOF

  tags = {
    Name = "Back-End 02 (us-east-1b)"
  }
}
