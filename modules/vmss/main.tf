resource "azurerm_subnet" "vmss" {
  name                 = "sn-vmss-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.254.1.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                = "vmss-${var.project_name}-${terraform.workspace}-${var.location}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  upgrade_mode        = "Manual"
  instances = var.instances
  sku = var.sku
  admin_username = var.admin_username
  custom_data = base64encode(file("${path.module}/cloud-init.sh"))

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss.id
      application_gateway_backend_address_pool_ids = var.backend_address_pool_ids
    }
  }
}
