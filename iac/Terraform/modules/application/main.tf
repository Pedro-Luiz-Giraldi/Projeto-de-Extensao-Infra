# =========================================================
# APPLICATION LOAD BALANCER & TARGET GROUP
# =========================================================

resource "aws_lb" "publico" {
  name               = "sax-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.public_subnet_1_id, var.public_subnet_2_id]
  security_groups    = [var.alb_security_group_id]

  tags = {
    Name = "sax-alb"
  }
}

resource "aws_lb_target_group" "web_servers" {
  name     = "sax-tg-frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/"
    interval = 30
  }

  tags = {
    Name = "sax-tg-frontend"
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
# WEB SERVERS (Ubuntu 26.04 + Docker)
# =========================================================

resource "aws_instance" "web_server_01" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_1_id
  vpc_security_group_ids = [var.web_server_security_group_id, var.swarm_security_group_id]

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
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
  EOF

  tags = {
    Name = "sax-ec2-frontend-1"
  }
}

resource "aws_instance" "web_server_02" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_2_id
  vpc_security_group_ids = [var.web_server_security_group_id, var.swarm_security_group_id]

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
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
  EOF

  tags = {
    Name = "sax-ec2-frontend-2"
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
# BACKEND SERVERS (Ubuntu 26.04 + Docker)
# =========================================================

resource "aws_instance" "backend_01" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.private_subnet_1_id
  vpc_security_group_ids = [var.backend_security_group_id, var.swarm_security_group_id]

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
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
  EOF

  tags = {
    Name = "sax-ec2-backend-1"
  }
}

resource "aws_instance" "backend_02" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.private_subnet_2_id
  vpc_security_group_ids = [var.backend_security_group_id, var.swarm_security_group_id]

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
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
  EOF

  tags = {
    Name = "sax-ec2-backend-2"
  }
}
