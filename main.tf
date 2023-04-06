#Configure the Azure provider
#curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.49.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Output
output "swarm_manager" {
  value = azurerm_linux_virtual_machine.swarm_manager.public_ip_address
}
output "swarm_worker_1" {
  value = azurerm_linux_virtual_machine.swarm_worker_1.public_ip_address
}
output "swarm_worker_2" {
  value = azurerm_linux_virtual_machine.swarm_worker_2.public_ip_address
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "swarm"
  location = "Central India"
  tags = {
    usedby = "swarm"
  }

}

# NIC - Manager
resource "azurerm_network_interface" "nic" {
  name                = "swarm_machine_nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_manager.id
  }

  tags = azurerm_resource_group.rg.tags
}


# NIC - Worker Node 1
resource "azurerm_network_interface" "nic_worker_1" {
  name                = "swarm_machine_nic_worker_1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_worker_1.id

  }

  tags = azurerm_resource_group.rg.tags
}


# NIC - Worker Node 2
resource "azurerm_network_interface" "nic_worker_2" {
  name                = "swarm_machine_nic_worker_2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_worker_2.id

  }

  tags = azurerm_resource_group.rg.tags
}

# Public IP Manager
resource "azurerm_public_ip" "public_manager" {
  name                = "nodeipmanager"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = azurerm_resource_group.rg.tags
}


# Public IP Worker 1
resource "azurerm_public_ip" "public_worker_1" {
  name                = "nodeipworker1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = azurerm_resource_group.rg.tags
}

# Public IP Worker 2
resource "azurerm_public_ip" "public_worker_2" {
  name                = "nodeipworker2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = azurerm_resource_group.rg.tags
}


#Swarm Manager Node
resource "azurerm_linux_virtual_machine" "swarm_manager" {
  name                = "manager"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./swarm_machine.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = azurerm_resource_group.rg.tags
}

#Swarm Worker 1
resource "azurerm_linux_virtual_machine" "swarm_worker_1" {
  name                = "worker1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic_worker_1.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./swarm_machine.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = azurerm_resource_group.rg.tags
}


#Swarm Worker 2
resource "azurerm_linux_virtual_machine" "swarm_worker_2" {
  name                = "worker2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic_worker_2.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./swarm_machine.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = azurerm_resource_group.rg.tags
}



# Network Association
resource "azurerm_subnet_network_security_group_association" "network_association" {
  subnet_id                 = azurerm_subnet.snet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

}

# Network Security Group 
resource "azurerm_network_security_group" "nsg" {
  name                = "swarm_nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_https"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "cluster_management_raft_sync_comm_tcp"
    priority                   = 400
    direction                  = "Inbound"
    protocol                   = "Tcp"
    access                     = "Allow"
    source_port_range          = "*"
    destination_port_range     = "2377"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "control_plane_tcp"
    priority                   = 500
    direction                  = "Inbound"
    protocol                   = "Tcp"
    access                     = "Allow"
    source_port_range          = "*"
    destination_port_range     = "7946"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "control_plane_udp"
    priority                   = 600
    direction                  = "Inbound"
    protocol                   = "Udp"
    access                     = "Allow"
    source_port_range          = "*"
    destination_port_range     = "7946"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "data_udp"
    priority                   = 700
    direction                  = "Inbound"
    protocol                   = "Udp"
    access                     = "Allow"
    source_port_range          = "*"
    destination_port_range     = "4789"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "overlay"
    priority                    = 800
    direction                  = "Inbound"
    protocol                   = "Esp"
    access                     = "Allow"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = azurerm_resource_group.rg.tags
}

# Virtual Net
resource "azurerm_virtual_network" "vnet" {
  name                = "swarm_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = azurerm_resource_group.rg.tags
}

# Subnet 
resource "azurerm_subnet" "snet" {
  name                 = "swarm_internal_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

}
