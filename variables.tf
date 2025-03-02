# Variáveis (variables.tf)
variable "projeto" {
  description = "Nome do projeto"
  type        = string
  default     = "VExpenses"
}

variable "candidato" {
  description = "Nome do candidato"
  type        = string
  default     = "SeuNome"
}

variable "allowed_ssh_ips" {
  description = "IPs permitidos para SSH (formato CIDR)"
  type        = list(string)
  default     = [<"SEU_IP_PUBLICO/32">] # Exemplo: ["123.45.67.89/32"]
}