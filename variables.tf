variable "resource_group_location" {
    default = "northeurope"
    description = "Location of resource group."
}

variable "resource_location_short_name" {
    default = "mneu"
    description = "Short name for resource location"
}

variable "resource_group_name_prefix" {
    default = "rg"
    description = "Prefix of the resoure group."
}

variable "environment" {
    default = "dev"
    description = "Environment for system being deployed."
}

variable "system_name" {
    default = "modelserving"
    description = "Name for system being deployed."
}

variable "service_principal_client_id" {
  description = "Azure Kubernetes Service Cluster service principal client ID. "
}

variable "service_principal_client_secret" {
  description = "Azure Kubernetes Service Cluster client secret."
}