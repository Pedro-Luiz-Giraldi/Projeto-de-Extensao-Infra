provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "principal" {
  cidr_block           = "10.0.0.0/22"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-Principal"
  }
}

resource "aws_internet_gateway" "principal" {
  tags = {
    Name = "IGW-Principal"
  }
}

resource "aws_internet_gateway_attachment" "principal" {
  vpc_id              = aws_vpc.principal.id
  internet_gateway_id = aws_internet_gateway.principal.id
}

resource "aws_subnet" "publica_1" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Sub-net publica - 10.0.0.0/26 | us-east-1a"
  }
}

resource "aws_subnet" "publica_2" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = "10.0.0.64/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Sub-net publica - 10.0.0.64/26 | us-east-1b"
  }
}

resource "aws_subnet" "privada_1" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = "10.0.2.0/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Sub-net privada - 10.0.2.0/26 | us-east-1a"
  }
}

resource "aws_subnet" "privada_2" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = "10.0.2.64/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Sub-net privada - 10.0.2.64/26 | us-east-1b"
  }
}

resource "aws_eip" "nat_gateway_1" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway_attachment.principal]
}

resource "aws_nat_gateway" "principal_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id     = aws_subnet.publica_1.id

  tags = {
    Name = "NAT-Gateway-1a"
  }
}

resource "aws_eip" "nat_gateway_2" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway_attachment.principal]
}

resource "aws_nat_gateway" "principal_2" {
  allocation_id = aws_eip.nat_gateway_2.id
  subnet_id     = aws_subnet.publica_2.id

  tags = {
    Name = "NAT-Gateway-1b"
  }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name = "RouteTable-Publica"
  }
}

resource "aws_route" "publica_padrao" {
  route_table_id         = aws_route_table.publica.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.principal.id

  depends_on = [aws_internet_gateway_attachment.principal]
}

resource "aws_route_table_association" "publica_1" {
  subnet_id      = aws_subnet.publica_1.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table_association" "publica_2" {
  subnet_id      = aws_subnet.publica_2.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table" "privada_1" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name = "RouteTable-Privada-1a"
  }
}

resource "aws_route" "privada_padrao_1" {
  route_table_id         = aws_route_table.privada_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.principal_1.id
}

resource "aws_route_table_association" "privada_1" {
  subnet_id      = aws_subnet.privada_1.id
  route_table_id = aws_route_table.privada_1.id
}

resource "aws_route_table" "privada_2" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name = "RouteTable-Privada-1b"
  }
}

resource "aws_route" "privada_padrao_2" {
  route_table_id         = aws_route_table.privada_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.principal_2.id
}

resource "aws_route_table_association" "privada_2" {
  subnet_id      = aws_subnet.privada_2.id
  route_table_id = aws_route_table.privada_2.id
}

resource "aws_security_group" "alb" {
  description = "SG para o Application Load Balancer"
  vpc_id      = aws_vpc.principal.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [var.my_ip]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-ALB"
  }
}

resource "aws_security_group" "web_server" {
  description = "SG para os Servidores Web (Nginx/HTTP)"
  vpc_id      = aws_vpc.principal.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.my_ip]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-WebServer"
  }
}

resource "aws_security_group" "backend" {
  description = "SG para os Servidores Back-End (Java)"
  vpc_id      = aws_vpc.principal.id

  ingress {
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.web_server.id]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.web_server.id]
  }

  ingress {
    description = "Acesso SSH para gestao"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.my_ip]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Backend"
  }
}

locals {
  swarm_ports = {
    cluster_management     = { protocol = "tcp", port = 2377 }
    node_communication_tcp = { protocol = "tcp", port = 7946 }
    node_communication_udp = { protocol = "udp", port = 7946 }
    overlay_network        = { protocol = "udp", port = 4789 }
  }
}

resource "aws_security_group_rule" "web_swarm_self" {
  for_each = local.swarm_ports

  type              = "ingress"
  description       = "Docker Swarm - ${each.key} (nos SG-WebServer)"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.web_server.id
  self              = true
}

resource "aws_security_group_rule" "web_swarm_from_backend" {
  for_each = local.swarm_ports

  type                     = "ingress"
  description              = "Docker Swarm - ${each.key} (nos SG-Backend)"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.web_server.id
  source_security_group_id = aws_security_group.backend.id
}

resource "aws_security_group_rule" "backend_swarm_self" {
  for_each = local.swarm_ports

  type              = "ingress"
  description       = "Docker Swarm - ${each.key} (nos SG-Backend)"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.backend.id
  self              = true
}

resource "aws_security_group_rule" "backend_swarm_from_web" {
  for_each = local.swarm_ports

  type                     = "ingress"
  description              = "Docker Swarm - ${each.key} (nos SG-WebServer)"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.backend.id
  source_security_group_id = aws_security_group.web_server.id
}

resource "aws_security_group" "database" {
  description = "SG para o Servidor de Banco de Dados MySQL (EC2)"
  vpc_id      = aws_vpc.principal.id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.backend.id]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.web_server.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "SG-EC2-Database"
    Project     = "Projeto-Extensao"
    Environment = "Production"
  }
}
