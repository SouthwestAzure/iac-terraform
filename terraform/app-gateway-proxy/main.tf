provider "azurerm" {
  version = "=1.22.1"
}

variable "rg_name" { }

variable "gateway_name" { }

variable gateway_ip_config_name { }

variable "gateway_instance_count" {
  default = 1
}

variable "vnet_name" { }

variable "public_ip_name" { }

variable "public_ip_dns" { }

variable "location" {
  default = "westus2"
}

variable "backend_fqdns" {
    type = "list"
    description = "List of security group IDs."
    default = []
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.rg_name}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.10.1.0/24"
}

resource "azurerm_subnet" "backend" {
  name                 = "backend"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.10.2.0/24"
}

resource "azurerm_public_ip" "ip" {
  name                = "${var.public_ip_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  domain_name_label   = "${var.public_ip_dns}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}-rqrt"
  probe_name                     = "${azurerm_virtual_network.vnet.name}-probe"
}

resource "azurerm_application_gateway" "network" {
  name                = "${var.gateway_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = "${var.gateway_instance_count}"
  }

  gateway_ip_configuration {
    name      = "${var.gateway_ip_config_name}"
    subnet_id = "${azurerm_subnet.frontend.id}"
  }

  # probe {
  #     name                = "${local.probe_name}"
  #     path                = "/"
  #     interval            = 30
  #     timeout             = 30
  #     protocol            = "Http"
  #     unhealthy_threshold = 3
  #     #host                = "${var.backend_fqdns[0]}"
  #     pick_host_name_from_backend_http_settings = "true"
  # }

  frontend_port {
    name = "${local.frontend_port_name}"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${local.frontend_ip_configuration_name}"
    public_ip_address_id = "${azurerm_public_ip.ip.id}"
  }

  backend_address_pool {
    name  = "${local.backend_address_pool_name}"
    fqdns = ["${var.backend_fqdns}"]
  }

  backend_http_settings {
    name                  = "${local.http_setting_name}"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    #probe_name            = "${local.probe_name}"
  }

  http_listener {
    name                           = "${local.listener_name}"
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}"
    frontend_port_name             = "${local.frontend_port_name}"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${local.request_routing_rule_name}"
    rule_type                  = "Basic"
    http_listener_name         = "${local.listener_name}"
    backend_address_pool_name  = "${local.backend_address_pool_name}"
    backend_http_settings_name = "${local.http_setting_name}"
  }
}