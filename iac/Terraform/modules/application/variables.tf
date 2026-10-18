variable "vpc_id" {
  description = "ID da VPC principal da stack network"
  type        = string
}

variable "public_subnet_1_id" {
  description = "ID da subnet publica us-east-1a da stack network"
  type        = string
}

variable "public_subnet_2_id" {
  description = "ID da subnet publica us-east-1b da stack network"
  type        = string
}

variable "private_subnet_1_id" {
  description = "ID da subnet privada us-east-1a da stack network"
  type        = string
}

variable "private_subnet_2_id" {
  description = "ID da subnet privada us-east-1b da stack network"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID do Security Group do ALB da stack network"
  type        = string
}

variable "web_server_security_group_id" {
  description = "ID do Security Group dos servidores Web da stack network"
  type        = string
}

variable "backend_security_group_id" {
  description = "ID do Security Group dos servidores Backend da stack network"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para os servidores Web e Back-End"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t2.micro", "t3.small"], var.instance_type)
    error_message = "Deve ser um tipo de instancia valido."
  }
}

variable "ami_id" {
  description = "Nome do parametro SSM da AMI Ubuntu 24.04 LTS em us-east-1"
  type        = string
  default     = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

variable "key_name" {
  description = "Nome do KeyPair para acesso SSH as instancias"
  type        = string
  default     = "vockey"
}
