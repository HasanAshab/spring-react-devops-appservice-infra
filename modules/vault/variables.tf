variable "name" {
  description = "Name of Private DNS Zone"
  type        = string
}

variable "location" {
  description = "Location of all resources"
  type        = string

  validation {
    condition     = length(regexall(" ", var.location)) == 0
    error_message = "Location must not contain spaces"
  }
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "secrets" {
  description = "Secret Names"
  type = set(object({
    name             = string
    value_wo         = string
    value_wo_version = number
  }))

  validation {
    condition     = length(var.secrets) > 0
    error_message = "You must provide at least one secret."
  }
}
