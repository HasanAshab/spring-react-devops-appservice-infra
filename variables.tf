variable "location" {
  description = "Location of all resources"
  type        = string

  validation {
    condition     = length(regexall(" ", var.location)) == 0
    error_message = "Location must not contain spaces"
  }
}

variable "appgw_sku" {
  description = "SKU of Application Gateway"
  type        = string
}

variable "appgw_port" {
  description = "Port of Application Gateway"
  type        = number
}

variable "web_sku" {
  description = "SKU of VM-Scale Set"
  type        = string
}

variable "web_instances" {
  description = "Number of instances in VM-Scale Set"
  type        = number
}

variable "web_image_offer" {
  description = "Offer of the OS image"
  type        = string
}

variable "web_image_sku" {
  description = "SKU/Variant of the OS image"
  type        = string
}

variable "web_public_key_path" {
  description = "Path to SSH Public Key"
  type        = string
}