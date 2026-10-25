variable "my_ip" {
  description = "Endereco IP em formato CIDR para liberacao de acesso administrativo (SSH/HTTP)"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.my_ip)) && length(var.my_ip) >= 9 && length(var.my_ip) <= 18
    error_message = "Deve ser um range CIDR valido (ex 203.0.113.1/32)."
  }
}

variable "vpc_cidr" {
  description = "CIDR block da VPC principal"
  type        = string
  default     = "10.0.0.0/22"
}

variable "availability_zones" {
  description = "Zonas de disponibilidade usadas para distribuir as subnets publicas e privadas"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Informe ao menos 2 Zonas de Disponibilidade."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets publicas (indice 0 = primeira AZ, indice 1 = segunda AZ)"
  type        = list(string)
  default     = ["10.0.0.0/26", "10.0.0.64/26"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Devem ser informados exatamente 2 CIDRs de subnets publicas."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas (0=priv_1a, 1=priv_1b, 2=subnet dedicada do banco de dados)"
  type        = list(string)
  default     = ["10.0.2.0/26", "10.0.2.64/26", "10.0.2.128/26"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "Devem ser informados exatamente 3 CIDRs de subnets privadas."
  }
}
