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
