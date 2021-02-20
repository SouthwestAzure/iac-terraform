data "azurerm_client_config" "current" { }

variable "resource_group_name" { }

variable "storage_account_name" { }

variable "keyvault_name" { }

variable "keyvault_object_id" { }

variable "location" {
  default = "westus2"
}

resource "azurerm_resource_group" "group" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_storage_account" "storage" {
  name                     = "${var.storage_account_name}"
  resource_group_name      = "${azurerm_resource_group.group.name}"
  location                 = "${var.location}"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_key_vault" "keyvault" {
  name                            = "${var.keyvault_name}"
  resource_group_name             = "${azurerm_resource_group.group.name}"
  location                        = "${var.location}"
  tenant_id                       = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "standard"
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${var.keyvault_object_id}"

    key_permissions = [
      "create",
      "delete",
      "get",
    ]

    secret_permissions = [
      "delete",
      "get",
      "set",
    ]
  }
}