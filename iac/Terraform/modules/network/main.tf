resource "aws_vpc" "principal" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "sax-vpc"
  }
}

resource "aws_internet_gateway" "principal" {
  tags = {
    Name = "sax-igw"
  }
}

resource "aws_internet_gateway_attachment" "principal" {
  vpc_id              = aws_vpc.principal.id
  internet_gateway_id = aws_internet_gateway.principal.id
}

resource "aws_subnet" "publica_1" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "sax-subnet-public-1"
  }
}

resource "aws_subnet" "publica_2" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "sax-subnet-public-2"
  }
}

resource "aws_subnet" "privada_1" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = var.private_subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "sax-subnet-private-1"
  }
}

resource "aws_subnet" "privada_2" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = var.private_subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "sax-subnet-private-2"
  }
}

resource "aws_subnet" "privada_db" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = var.private_subnet_cidrs[2]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "sax-subnet-private-db"
  }
}

resource "aws_eip" "nat_gateway_1" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway_attachment.principal]

  tags = {
    Name = "sax-eip-nat-1"
  }
}

resource "aws_nat_gateway" "principal_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id     = aws_subnet.publica_1.id

  tags = {
    Name = "sax-nat-1"
  }
}

resource "aws_eip" "nat_gateway_2" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway_attachment.principal]

  tags = {
    Name = "sax-eip-nat-2"
  }
}

resource "aws_nat_gateway" "principal_2" {
  allocation_id = aws_eip.nat_gateway_2.id
  subnet_id     = aws_subnet.publica_2.id

  tags = {
    Name = "sax-nat-2"
  }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name = "sax-rt-public"
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
    Name = "sax-rt-private-1"
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

resource "aws_route_table_association" "privada_db" {
  subnet_id      = aws_subnet.privada_db.id
  route_table_id = aws_route_table.privada_1.id
}

resource "aws_route_table" "privada_2" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name = "sax-rt-private-2"
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
    Name = "sax-sg-alb"
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
    Name = "sax-sg-frontend"
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
    Name = "sax-sg-backend"
  }
}

resource "aws_security_group" "swarm" {
  description = "SG para trafego do Docker Swarm (nos Web e Backend)"
  vpc_id      = aws_vpc.principal.id

  ingress {
    description = "Gerenciamento do cluster Docker Swarm"
    protocol    = "tcp"
    from_port   = 2377
    to_port     = 2377
    self        = true
  }

  ingress {
    description = "Comunicação entre nós do Docker Swarm (TCP)"
    protocol    = "tcp"
    from_port   = 7946
    to_port     = 7946
    self        = true
  }

  ingress {
    description = "Comunicação entre nós do Docker Swarm (UDP)"
    protocol    = "udp"
    from_port   = 7946
    to_port     = 7946
    self        = true
  }

  ingress {
    description = "Rede overlay do Docker Swarm (VXLAN)"
    protocol    = "udp"
    from_port   = 4789
    to_port     = 4789
    self        = true
  }

  tags = {
    Name = "sax-sg-swarm"
  }
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
    Name = "sax-sg-database"
  }
}
