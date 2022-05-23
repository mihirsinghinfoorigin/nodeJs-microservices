terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  backend "azurerm" {
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.resource_group}_${var.environment}"
  location = var.location
}

resource "azurerm_network_security_group" "vnet_security_group" {
  name                = "k8stest_security_group"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_network" "k8s_vnet" {
  name                = "k8s_vnet"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "k8s-nodepool" {
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.k8s_vnet.name
  resource_group_name  = azurerm_resource_group.resource_group.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "k8s_vnet_subnet" {
    name             = "k8s_vnet_subnet"
    virtual_network_name = azurerm_virtual_network.k8s_vnet.name
    resource_group_name = azurerm_resource_group.resource_group.name
    address_prefixes     = ["10.0.0.0/24"]
    service_endpoints    = ["Microsoft.KeyVault","Microsoft.Sql"]
}

resource "azurerm_key_vault" "api_key_vault" {
  name                        = var.api_key_vault
  location                    = azurerm_resource_group.resource_group.location
  resource_group_name         = azurerm_resource_group.resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "Create",
      "List",
      "Delete",
      "Recover",
      "Purge"
    ]

    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
      "Recover",
      "Purge"
    ]

    storage_permissions = [
      "Get",
    ]
  }

  #network_acls {
  #  default_action             = "Deny"
  #  bypass                     = "AzureServices"
  #  virtual_network_subnet_ids = [azurerm_subnet.k8s_vnet_subnet.id]
  #}
}

resource "azurerm_key_vault_secret" "api_key_vault_secret" {
  name         = var.api_key_vault_secret
  value        = var.api_key_vault_secret_value
  key_vault_id = azurerm_key_vault.api_key_vault.id
}

provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "terraform-k8s" {
  name                = "${var.cluster_name}_${var.environment}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
  
  #network_profile {
  #  network_plugin = "azure"
  #  network_policy = "azure"
  #  service_cidr = "10.0.4.0/24"
  #  dns_service_ip = "10.0.4.10"
  #  docker_bridge_cidr = "172.17.0.1/16"
  #}

  default_node_pool {
    name       = "agentpool"
    node_count = var.node_count
    vm_size    = "standard_b2ms"
  #  vnet_subnet_id = azurerm_subnet.k8s-nodepool.id
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = {
    Environment = var.environment
  }
}
