variable "resource_group_name" { }

variable "location" {
  default = "westus2"
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