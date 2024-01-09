///
// Creates the following networking for the VM:
// - Virtual Network and Subnet to prevent public access to the cluster.
// - (Optionally) Network Security Groups to give WAN IP access to the VM for kubectl or ssh. Not needed 
//   if using `az connectedk8s proxy`.
///

locals {
  should_determine_wan_ip        = var.should_allow_list_wan_ip && var.current_wan_ip == null
  should_allow_list_ssh_port     = var.should_allow_list_wan_ip && var.should_allow_list_ssh_port
  should_allow_list_kubectl_port = var.should_allow_list_wan_ip && var.should_allow_list_kubectl_port
  should_allow_list_rdp_port     = var.should_allow_list_wan_ip && var.should_allow_list_rdp_port
  current_wan_ip                 = local.should_determine_wan_ip ? data.http.ip[0].response_body : var.current_wan_ip
}

// Gets your current IP if one wasn't provided.

data "http" "ip" {
  count = local.should_determine_wan_ip ? 1 : 0
  url   = "https://ifconfig.me/ip"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name}"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  name                 = "subnet-${var.name}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_address_space]
}

resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

// Allows SSH into the VM.

resource "azurerm_network_security_rule" "allow_ssh" {
  count = local.should_allow_list_ssh_port ? 1 : 0
  name  = "AllowMyIpAddressToVNetTCP22"

  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = azurerm_resource_group.this.name

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

// Allows kubectl into the VM.

resource "azurerm_network_security_rule" "allow_kubectl" {
  count = local.should_allow_list_kubectl_port ? 1 : 0
  name  = "AllowMyIpAddressToVNetTCP6443"

  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = azurerm_resource_group.this.name

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

resource "azurerm_network_security_rule" "allow_rdp_tcp" {
  count = local.should_allow_list_rdp_port ? 1 : 0
  name  = "AllowMyIpAddressToVNetTCP3389"

  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = azurerm_resource_group.this.name

  priority                   = 1012
  description                = "WAN IP access to port 3389 for RDP"
  access                     = "Allow"
  source_address_prefix      = local.current_wan_ip
  source_port_range          = "*"
  destination_address_prefix = "VirtualNetwork"
  destination_port_range     = "3389"
  protocol                   = "Tcp"
  direction                  = "Inbound"
}

resource "azurerm_network_security_rule" "allow_rdp_udp" {
  count = local.should_allow_list_rdp_port ? 1 : 0
  name  = "AllowMyIpAddressToVNetUDP3389"

  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = azurerm_resource_group.this.name

  priority                   = 1013
  description                = "WAN IP access to port 3389 for RDP"
  access                     = "Allow"
  source_address_prefix      = local.current_wan_ip
  source_port_range          = "*"
  destination_address_prefix = "VirtualNetwork"
  destination_port_range     = "3389"
  protocol                   = "Udp"
  direction                  = "Inbound"
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}
