primary_location = "centralus"
enable_telemetry = false

# asp
asp_sku                   = "B1"
asp_worker_count          = 1
asp_enable_zone_balancing = false
asp_enable_autoscale      = false

# database
database_sku                         = "B_Standard_B1ms"
database_version                     = "8.0.21"
database_enable_geo_redundant_backup = false
database_name                        = "db"
database_admin_username              = "admin4321"

# backend
backend_docker_registry_url = "https://ghcr.io/hasanashab"
backend_docker_image_name   = "spring-react-devops-appservice-backend"

# frontend
frontend_docker_registry_url = "https://ghcr.io/hasanashab"
frontend_docker_image_name   = "spring-react-devops-appservice-frontend"
