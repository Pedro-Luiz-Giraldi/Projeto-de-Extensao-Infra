variable "aws_region" {
  description = "Regiao AWS onde os recursos serao provisionados"
  type        = string
  default     = "us-east-1"
}

variable "my_ip" {
  description = "Endereco IP em formato CIDR para liberacao de acesso administrativo (SSH/HTTP)"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.my_ip)) && length(var.my_ip) >= 9 && length(var.my_ip) <= 18
    error_message = "Deve ser um range CIDR valido (ex 203.0.113.1/32)."
  }
}

variable "app_instance_type" {
  description = "Tipo de instancia EC2 para os servidores Web e Back-End"
  type        = string
  default     = "t3.small"

  validation {
    condition     = contains(["t3.micro", "t2.micro", "t3.small"], var.app_instance_type)
    error_message = "Deve ser um tipo de instancia valido."
  }
}

variable "app_key_name" {
  description = "Nome do KeyPair para acesso SSH as instancias Web e Back-End"
  type        = string
  default     = "vockey"
}

variable "db_instance_type" {
  description = "Tipo de instancia EC2 para o servidor MySQL"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.db_instance_type)
    error_message = "Deve ser um tipo de instancia valido."
  }
}

variable "db_key_name" {
  description = "Nome do KeyPair para acesso SSH a instancia do banco de dados"
  type        = string
  default     = "vockey"
}
