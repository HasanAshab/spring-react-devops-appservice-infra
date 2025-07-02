location = "centralus"

# database
database_sku     = "B_Standard_B1ms"
database_version = "8.0.21"
database_name    = "db1"

# backend
backend_sku                 = "B1"
backend_worker_count        = 2
backend_docker_registry_url = "https://ghcr.io/hasanashab"
backend_docker_image_name   = "spring-react-devops-backendservice-backend"

# frontend
frontend_sku                 = "B1"
frontend_worker_count        = 2
frontend_docker_registry_url = "https://ghcr.io/hasanashab"
frontend_docker_image_name   = "spring-react-devops-backendservice-frontend"

