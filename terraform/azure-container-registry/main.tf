variable "resource_group_name" { }

variable "container_registry_name" { }

variable "location" {
  default = "westus2"
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.container_registry_name}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  admin_enabled       = true
  sku                 = "Basic"
}