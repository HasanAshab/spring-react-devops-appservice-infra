primary_location = "centralus"
enable_telemetry = false

# asp
asp_sku          = "B1"
asp_worker_count = 1

# database
database_sku             = "B_Standard_B1ms"
database_version         = "8.0.21"
database_name            = "db"
database_admin_username  = "admin4321"
database_storage_size_gb = 20

# backend
backend_docker_registry_url = "https://ghcr.io/hasanashab"
backend_docker_image_name   = "spring-react-devops-appservice-backend"

# frontend
frontend_docker_registry_url = "https://ghcr.io/hasanashab"
frontend_docker_image_name   = "spring-react-devops-appservice-frontend"

# front door
frontdoor_sku = "Standard_AzureFrontDoor"
