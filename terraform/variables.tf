variable "project" {
  type    = string
  default = "kubesage"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "domain_name" {
  type    = string
  default = "nexaflow.site"
}

variable "origin_host_name" {
  type    = string
  default = ""
}

variable "origin_host_header" {
  type    = string
  default = ""
}

variable "frontdoor_sku_name" {
  type    = string
  default = "Premium_AzureFrontDoor"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.42.0.0/16"]
}

variable "aks_subnet_prefix" {
  type    = list(string)
  default = ["10.42.1.0/24"]
}

variable "acr_name" {
  type    = string
  default = "acrkubesageprod"
}

variable "aks_name" {
  type    = string
  default = "aks-kubesage-prod"
}

variable "aks_node_count" {
  type    = number
  default = 2
}

variable "aks_vm_size" {
  type    = string
  default = "Standard_D4s_v5"
}

variable "postgres_admin_login" {
  type    = string
  default = "kubesageadmin"
}

variable "postgres_server_name" {
  type    = string
  default = null
}

variable "database_location" {
  type    = string
  default = null
}

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}

variable "postgres_sku_name" {
  type    = string
  default = "B_Standard_B2s"
}

variable "postgres_storage_mb" {
  type    = number
  default = 32768
}

variable "create_database" {
  type    = bool
  default = true
}
