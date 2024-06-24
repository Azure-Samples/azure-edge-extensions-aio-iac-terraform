locals {
  public_ip_name                 = "ip-${var.name}"
  network_interface_name         = "nic-${var.name}"
  virtual_network_name           = "vnet-${var.name}"
  subnet_name                    = "subnet-${var.name}"
  network_security_group_name    = "nsg-${var.name}"
  should_determine_wan_ip        = var.should_allow_list_wan_ip && var.current_wan_ip == null
  should_allow_list_ssh_port     = var.should_allow_list_wan_ip && var.should_allow_list_ssh_port
  should_allow_list_kubectl_port = var.should_allow_list_wan_ip && var.should_allow_list_kubectl_port
  current_wan_ip                 = local.should_determine_wan_ip ? data.http.ip[0].response_body : var.current_wan_ip
}

resource "azurerm_public_ip" "this" {
  count = var.should_create_network ? 1 : 0

  name                = local.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "this" {
  count = var.should_create_network ? 1 : 0

  name                = local.network_interface_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this[0].id
  }
}

data "http" "ip" {
  count = local.should_determine_wan_ip ? 1 : 0
  url   = "https://ifconfig.me/ip"
}

resource "azurerm_virtual_network" "this" {
  count = var.should_create_network ? 1 : 0

  name                = local.virtual_network_name
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "this" {
  count = var.should_create_network ? 1 : 0

  name                 = local.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.subnet_address_space]
}

resource "azurerm_network_security_group" "this" {
  count = var.should_create_network ? 1 : 0

  name                = local.network_security_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  count = var.should_create_network && var.should_allow_list_ssh_port ? 1 : 0

  name                        = "AllowMyIpAddressToVNetTCP22"
  network_security_group_name = azurerm_network_security_group.this[0].name
  resource_group_name         = var.resource_group_name

  priority                   = 1001
  description                = "WAN IP access to port 22"
  access                     = "Allow"
  source_address_prefix      = local.current_wan_ip
  source_port_range          = "*"
  destination_address_prefix = "VirtualNetwork"
  destination_port_range     = "22"
  protocol                   = "Tcp"
  direction                  = "Inbound"
}

resource "azurerm_network_security_rule" "allow_kubectl" {
  count = var.should_create_network && var.should_allow_list_kubectl_port ? 1 : 0
  name  = "AllowMyIpAddressToVNetTCP6443"

  network_security_group_name = azurerm_network_security_group.this[0].name
  resource_group_name         = var.resource_group_name

  priority                   = 1011
  description                = "WAN IP access to port 6443"
  access                     = "Allow"
  source_address_prefix      = local.current_wan_ip
  source_port_range          = "*"
  destination_address_prefix = "VirtualNetwork"
  destination_port_range     = "6443"
  protocol                   = "Tcp"
  direction                  = "Inbound"
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count = var.should_create_network ? 1 : 0

  subnet_id                 = azurerm_subnet.this[0].id
  network_security_group_id = azurerm_network_security_group.this[0].id
}
