variable "location" {
  description = "Location of all resources"
  type        = string

  validation {
    condition     = length(regexall(" ", var.location)) == 0
    error_message = "Location must not contain spaces"
  }
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "node_vm_size" {
  description = "VM Size of worker nodes"
  type        = string
}