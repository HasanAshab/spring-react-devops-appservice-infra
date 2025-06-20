resource "azurerm_resource_group" "main" {
  name     = "rg-${local.project_name}-${terraform.workspace}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${terraform.workspace}-${var.location}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = replace(self.name, "-", "")
  tags                = local.tags

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}
