variable "aws_region" {
  description = "Regiao AWS onde os recursos serao provisionados"
  type        = string
  default     = "us-east-1"
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

variable "key_name" {
  description = "Nome do KeyPair para acesso SSH a instancia"
  type        = string
  default     = "vockey"
}
