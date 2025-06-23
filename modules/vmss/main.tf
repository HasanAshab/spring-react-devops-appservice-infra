resource "azurerm_subnet" "vmss" {
  name                 = "sn-vmss-${var.project_name}-${terraform.workspace}-${var.location}-001"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [ var.sn_address_prefix ]
}

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                = "vmss-${var.project_name}-${terraform.workspace}-${var.location}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  upgrade_mode        = "Manual"
  instances = var.instances
  sku = var.sku
  admin_username = var.admin_username
  custom_data = base64encode(file(var.custom_data_path))

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
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
