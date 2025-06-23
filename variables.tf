variable "location" {
  description = "Location of all resources"
  type        = string

  validation {
    condition     = length(regexall(" ", var.location)) == 0
    error_message = "Location must not contain spaces"
  }
}

variable "vmss_sku" {
  description = "SKU of VM-Scale Set"
  type        = string
}

variable "vmss_instances" {
  description = "Number of instances in VM-Scale Set"
  type        = number
}

variable "vmss_public_key_path" {
  description = "Path to SSH Public Key"
  type        = string
}