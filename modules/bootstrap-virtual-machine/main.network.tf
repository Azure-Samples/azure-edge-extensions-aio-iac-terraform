resource "azurerm_public_ip" "this" {
  count = var.network_creation_enabled ? 1 : 0

  name                = "ip-${var.postfix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "this" {
  count = var.network_creation_enabled ? 1 : 0

  name                = "nic-${var.postfix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this[0].id
  }
}

resource "azurerm_virtual_network" "this" {
  count = var.network_creation_enabled ? 1 : 0

  name                = "vnet-${var.postfix}"
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "this" {
  count = var.network_creation_enabled ? 1 : 0

  name                 = "subnet-${var.postfix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.subnet_address_space]
}

resource "azurerm_network_security_group" "this" {
  count = var.network_creation_enabled ? 1 : 0

  name                = "nsg-${var.postfix}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count = var.network_creation_enabled ? 1 : 0

  subnet_id                 = azurerm_subnet.this[0].id
  network_security_group_id = azurerm_network_security_group.this[0].id
}
