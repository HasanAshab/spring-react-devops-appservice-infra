variable "location" {
  description = "Location of all resources"
  type        = string

  validation {
    condition     = length(regexall(" ", var.location)) == 0
    error_message = "Location must not contain spaces"
  }
}

variable "web_sku" {
  description = "SKU of VM-Scale Set"
  type        = string
}

variable "web_worker_count" {
  description = "Number of Workers"
  type        = number
}

variable "web_docker_registry_url" {
  description = "Docker Registry URL"
  type        = string
}

variable "web_docker_image_name" {
  description = "Docker Image Name"
  type        = string
}

variable "web_docker_image_tag" {
  description = "Docker Image Tag"
  type        = string
}


variable "app_sku" {
  description = "SKU of VM-Scale Set"
  type        = string
}

variable "app_worker_count" {
  description = "Number of Workers"
  type        = number
}

variable "app_docker_registry_url" {
  description = "Docker Registry URL"
  type        = string
}

variable "app_docker_image_name" {
  description = "Docker Image Name"
  type        = string
}

variable "app_docker_image_tag" {
  description = "Docker Image Tag"
  type        = string
}

variable "app_port" {
  description = "Port of Application"
  default     = 80
}

variable "mysql_sku" {
  description = "SKU of MySQL Server"
  type        = string
}

variable "mysql_version" {
  description = "Version of MySQL Server"
  type        = string
}

variable "mysql_admin_username" {
  description = "Username for MySQL Server"
  type        = string
}

variable "mysql_admin_password" {
  description = "Password for MySQL Server"
  type        = string
  sensitive = true
}

variable "mysql_db_name" {
  description = "Database Name"
  type        = string
}