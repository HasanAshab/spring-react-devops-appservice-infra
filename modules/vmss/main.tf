
resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                = "-vmss"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  upgrade_mode        = "Manual"
  instances = 2
  sku = var.sku
  admin_username = "adminuser"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  network_interface {
    name    = "example-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.example.id

      application_gateway_backend_address_pools_ids = [ module.appgw.backend_address_pool_id ]
    }
  }
}
