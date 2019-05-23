


resource "azurerm_resource_group" "AppRG" {
   
   name = "example-name"
   location = "West US"
}


resource "azurerm_virtual_network" "App-VNET" {
  name                = "App-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.AppRG.location}"
  resource_group_name = "${azurerm_resource_group.AppRG.name}"
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.AppRG.name}"
  virtual_network_name = "${azurerm_virtual_network.App-VNET.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "example" {
  name                = "${var.prefix}-publicip"
  resource_group_name = "${azurerm_resource_group.example.name}"
  location            = "${azurerm_resource_group.example.location}"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "example" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"

        ip_configuration {
            name                          = "configuration"
            subnet_id                     = "${azurerm_subnet.example.id}"
            private_ip_address_allocation = "Dynamic"
            public_ip_address_id          = "${azurerm_public_ip.example.id}"
        }
}





resource "azurerm_virtual_machine" "VM" {
   name = "GLOIIS01"
   resource_group_name = "${azurerm_resource_group.test.name}"
   location = "${azurerm_resource_group.AppRG.location}"
   network_interface_ids = ["${azurerm_network_interface.example.id}"]
   vm_size = "Standard_A0"

    storage_os_disk 
         {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.virtual_machine_name}"
    admin_username = "${local.admin_username}"
    admin_password = "${local.admin_password}"
    custom_data    = "${local.custom_data_content}"
  }

  
}