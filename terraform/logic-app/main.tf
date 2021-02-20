variable "name_prefix" { }
variable "name_main" { }
variable "name_suffix" { }
variable "location" { }

locals {
  name_full = "${var.name_prefix}-${var.name_main}-${var.name_suffix}"
}

resource "azurerm_resource_group" "example" {
  name     = "${local.name_full}"
  location = "${var.location}"
}

resource "azurerm_logic_app_workflow" "example" {
  name                = "${local.name_full}"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
}

resource "azurerm_logic_app_trigger_recurrence" "hourly" {
  name         = "run-every-hour"
  logic_app_id = "${azurerm_logic_app_workflow.example.id}"
  frequency    = "Hour"
  interval     = 1
}

resource "azurerm_logic_app_action_http" "main" {
  name         = "clear-stale-objects"
  logic_app_id = "${azurerm_logic_app_workflow.example.id}"
  method       = "DELETE"
  uri          = "http://example.com/clear-stable-objects"
}