resource "azurerm_resource_group" "this" {
  name     = "rg-${local.project_name}-${terraform.workspace}"
  location = var.location
  tags = {
    Environment = terraform.workspace
    Service     = local.project_name
  }
}

module "network" {
  source              = "./modules/network"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.vnet_cidr]
}

module "dns" {
  source              = "./modules/dns"
  name                = local.dns_zone_name
  resource_group_name = azurerm_resource_group.this.name
  vnet_id             = module.network.id
}

module "mysql" {
  source              = "./modules/mysql"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  vnet_name           = module.network.name
  snet_address_prefix = cidrsubnet(local.vnet_cidr, 8, 2)
  private_dns_zone_id = module.dns.zone_id
  sku                 = var.mysql_sku
  db_version          = var.mysql_version
  admin_username      = var.mysql_admin_username
  admin_password      = var.mysql_admin_password
  db_name             = var.mysql_db_name
}

module "app" {
  source              = "./modules/app"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  vnet_name           = module.network.name
  snet_address_prefix = cidrsubnet(local.vnet_cidr, 8, 1)
  private_dns_zone_id = module.dns.zone_id
  sku                 = var.app_sku
  worker_count        = var.app_worker_count
  docker_registry_url = var.app_docker_registry_url
  docker_image_name   = var.app_docker_image_name
  docker_image_tag    = var.app_docker_image_tag
  app_settings = {
    "SPRING_DATASOURCE_URL"      = "jdbc:mysql://${module.mysql.fqdn}:3306/${var.mysql_db_name}?allowPublicKeyRetrieval=true&useSSL=true&createDatabaseIfNotExist=true&useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=Europe/Paris"
    "SPRING_DATASOURCE_USERNAME" = var.mysql_admin_username
    "SPRING_DATASOURCE_PASSWORD" = var.mysql_admin_password
    "SERVER_PORT"                = var.app_port
  }
}

module "web" {
  source              = "./modules/web"
  project_name        = local.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  vnet_name           = module.network.name
  snet_address_prefix = cidrsubnet(local.vnet_cidr, 8, 0)
  sku                 = var.web_sku
  worker_count        = var.web_worker_count
  docker_registry_url = var.web_docker_registry_url
  docker_image_name   = var.web_docker_image_name
  docker_image_tag    = var.web_docker_image_tag
}





# resource "azurerm_public_ip" "dns-testing" {
#   name                = "pip-dns-testing"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = var.location
#   allocation_method   = "Static"
# }
# resource "azurerm_subnet" "dns-testing" {
#   name                 = "snet-dns-testing"
#   resource_group_name  = azurerm_resource_group.this.name
#   virtual_network_name = module.network.name
#   address_prefixes     = [cidrsubnet(local.vnet_cidr, 8, 3)]

# }

# resource "azurerm_network_interface" "dns-testing" {
#   name                = "dns-testing"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.this.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.dns-testing.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id = azurerm_public_ip.dns-testing.id
#   } 
# }

# resource "azurerm_linux_virtual_machine" "dns-testing" {
#   name                = "dns-testing"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = var.location
#   size                = "Standard_B1s"
#   admin_username      = "adminuser"
#   network_interface_ids = [
#     azurerm_network_interface.dns-testing.id
#   ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("~/.ssh/hasan_rsa.pub")
#   }
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }
#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }
# }