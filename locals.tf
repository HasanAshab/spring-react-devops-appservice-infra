locals {
  project_name = "go-web-app"
}

locals {
  tags = {
    Project = local.project_name
  }
}