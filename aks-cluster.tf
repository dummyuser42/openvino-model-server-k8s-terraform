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

resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.resource_location_short_name}sa${var.environment}${var.system_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "${var.environment}"
    system_name = "${var.system_name}"
  }
}

resource "azurerm_storage_container" "storage_account_container" {
  name                  = "models"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "inception_model_bin" {
  name                   = "inception-resnet/1/inception-resnet-v2-tf.bin"
  type                   = "Block"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_account_container.name
  source                 = "public/inception-resnet-v2-tf/FP16/inception-resnet-v2-tf.bin"
}

resource "azurerm_storage_blob" "inception_model_mapping" {
  name                   = "inception-resnet/1/inception-resnet-v2-tf.mapping"
  type                   = "Block"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_account_container.name
  source                 = "public/inception-resnet-v2-tf/FP16/inception-resnet-v2-tf.mapping"
}

resource "azurerm_storage_blob" "inception_model_xml" {
  name                   = "inception-resnet/1/inception-resnet-v2-tf.xml"
  type                   = "Block"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_account_container.name
  source                 = "public/inception-resnet-v2-tf/FP16/inception-resnet-v2-tf.xml"
}