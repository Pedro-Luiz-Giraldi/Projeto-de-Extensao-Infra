variable "my_ip" {
  description = "Endereco IP em formato CIDR para liberacao de acesso administrativo (SSH/HTTP)"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.my_ip)) && length(var.my_ip) >= 9 && length(var.my_ip) <= 18
    error_message = "Deve ser um range CIDR valido (ex 203.0.113.1/32)."
  }
}
