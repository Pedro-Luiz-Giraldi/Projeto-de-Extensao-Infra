variable "private_subnet_1_id" {
  description = "ID da subnet privada us-east-1a da stack network"
  type        = string
}

variable "private_subnet_2_id" {
  description = "ID da subnet privada us-east-1b da stack network"
  type        = string
}

variable "database_security_group_id" {
  description = "ID do Security Group da stack network"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para o servidor MySQL"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Deve ser um tipo de instancia valido."
  }
}

variable "ami_id" {
  description = "Nome do parametro SSM da AMI Ubuntu 24.04 LTS em us-east-1"
  type        = string
  default     = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

variable "key_name" {
  description = "Nome do KeyPair para acesso SSH a instancia"
  type        = string
  default     = "vockey"
}

variable "db_username" {
  description = "Usuario master do banco de dados MySQL"
  type        = string
  default     = "dbadmin"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]*$", var.db_username)) && length(var.db_username) >= 4 && length(var.db_username) <= 16
    error_message = "O usuario deve ter de 4 a 16 caracteres alfanumericos e iniciar por uma letra."
  }
}

variable "db_password" {
  description = "Senha master do banco de dados MySQL"
  type        = string
  sensitive   = true
  default     = "AdminPassword123!"

  validation {
    condition     = length(var.db_password) >= 8 && length(var.db_password) <= 41
    error_message = "A senha deve ter de 8 a 41 caracteres."
  }
}

variable "db_name" {
  description = "Nome do banco de dados inicial"
  type        = string
  default     = "appdb"
}
