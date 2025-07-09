location         = "centralus"
enable_telemetry = false

# vault
vault_sku = "standard"

# database
database_sku                   = "B_Standard_B1ms"
database_version               = "8.0.21"
database_backup_retention_days = 3
database_name                  = "db-prod"
database_admin_username        = "admin4321"

# backend
backend_sku                 = "B1"
backend_worker_count        = 1
backend_docker_registry_url = "https://ghcr.io/hasanashab"
backend_docker_image_name   = "spring-react-devops-appservice-backend"

# frontend
frontend_sku                 = "B1"
frontend_worker_count        = 1
frontend_docker_registry_url = "https://ghcr.io/hasanashab"
frontend_docker_image_name   = "spring-react-devops-appservice-frontend"
