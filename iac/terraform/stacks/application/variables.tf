variable "aws_region" {
  description = "Regiao AWS onde os recursos serao provisionados"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para os servidores Web e Back-End"
  type        = string
  default     = "t3.small"

  validation {
    condition     = contains(["t3.micro", "t2.micro", "t3.small"], var.instance_type)
    error_message = "Deve ser um tipo de instancia valido."
  }
}
