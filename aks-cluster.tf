resource "azurerm_resource_group" "rg" {
    location = var.resource_group_location
    name = "${var.resource_location_short_name}-${var.resource_group_name_prefix}-${var.environment}-${var.system_name}"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.resource_location_short_name}-aks-${var.environment}-${var.system_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix = "${var.system_name}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.service_principal_client_id
    client_secret = var.service_principal_client_secret
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "${var.environment}"
    system_name = "${var.system_name}"
  }
}
