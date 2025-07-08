location = "centralus"

# database
database_sku     = "B_Standard_B1ms"
database_version = "8.0.21"
database_name    = "db1"

# backend
backend_sku                 = "B1"
backend_worker_count        = 1
backend_docker_registry_url = "https://ghcr.io/hasanashab"
backend_docker_image_name   = "spring-react-devops-backendservice-backend"

# web
web_sku                 = "B1"
web_worker_count        = 1
web_docker_registry_url = "https://ghcr.io/hasanashab"
web_docker_image_name   = "spring-react-devops-backendservice-frontend"
