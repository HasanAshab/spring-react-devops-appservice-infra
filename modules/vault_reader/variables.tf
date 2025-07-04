variable "name" {
  description = "Name of Private DNS Zone"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "secrets" {
  description = "Secret Names"
  type        = set(string)

  validation {
    condition     = length(var.secrets) > 0
    error_message = "You must provide at least one secret."
  }
}
