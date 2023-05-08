resource "azurerm_resource_group" "rg" {
    location = var.resource_group_location
    name = "${var.resource_location_short_name}-${var.resource_group_name_prefix}-${var.environment}-${var.system_name}"
}