variable "location" {
  description = "Location of all resources"
  type        = string
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "node_vm_size" {
  description = "VM Size of worker nodes"
  type        = string
}