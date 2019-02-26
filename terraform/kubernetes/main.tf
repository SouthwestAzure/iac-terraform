variable "resource_group_name" { }

variable "container_registry_name" { }

variable "aks_service_name" { }

variable "location" { }

variable "service_principal_name" { }

variable "service_principal_pwd" { }

variable "node_count" {
  default = "3"
}

terraform {
  backend "azurerm" {
    environment = "public"
  }
}

resource "azurerm_resource_group" "group" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.container_registry_name}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  location            = "${azurerm_resource_group.group.location}"
  admin_enabled       = true
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.aks_service_name}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  location            = "${azurerm_resource_group.group.location}"
  dns_prefix          = "${var.aks_service_name}"

  agent_pool_profile {
    name    = "agentpool"
    count   = "${var.node_count}"
    vm_size = "Standard_DS2_v2"
    os_type = "Linux"
  }

  service_principal {
    client_id     = "${var.service_principal_name}"
    client_secret = "${var.service_principal_pwd}"
  }

  addon_profile {
    http_application_routing {
      enabled = true
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}