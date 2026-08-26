variable "private_subnet_1_id" {
  description = "ID da subnet privada us-east-1a da stack network"
  type        = string
}

variable "private_subnet_2_id" {
  description = "ID da subnet privada us-east-1b da stack network"
  type        = string
}

variable "database_security_group_id" {
  description = "ID do Security Group do RDS da stack network"
  type        = string
}

variable "db_username" {
  description = "Usuario master do banco de dados RDS"
  type        = string
  default     = "dbadmin"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]*$", var.db_username)) && length(var.db_username) >= 4 && length(var.db_username) <= 16
    error_message = "O usuario deve ter de 4 a 16 caracteres alfanumericos e iniciar por uma letra."
  }
}

variable "db_password" {
  description = "Senha master do banco de dados RDS"
  type        = string
  sensitive   = true
  default     = "AdminPassword123!"

  validation {
    condition     = length(var.db_password) >= 8 && length(var.db_password) <= 41
    error_message = "A senha deve ter de 8 a 41 caracteres."
  }
}
