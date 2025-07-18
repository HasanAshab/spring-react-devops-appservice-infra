primary_location   = "centralus"
secondary_location = "eastus"
enable_telemetry   = true

# asp
asp_sku                        = "S1"
asp_worker_count               = 2
asp_enable_zone_balancing      = true
asp_enable_autoscale           = true
asp_autoscale_default_capacity = 2
asp_autoscale_minimum_capacity = 2
asp_autoscale_maximum_capacity = 5

# database
database_sku                         = "B_Standard_B1ms"
database_version                     = "8.0.21"
database_enable_geo_redundant_backup = true
database_backup_retention_days       = 7
database_name                        = "db"
database_admin_username              = "admin4321"

# backend
backend_docker_registry_url = "https://ghcr.io/hasanashab"
backend_docker_image_name   = "spring-react-devops-appservice-backend"

# frontend
frontend_docker_registry_url = "https://ghcr.io/hasanashab"
frontend_docker_image_name   = "spring-react-devops-appservice-frontend"
