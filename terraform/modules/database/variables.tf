variable "name_prefix" { type = string }
variable "database_name" { type = string }
variable "server_name" {
  type    = string
  default = null
}
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "administrator_login" { type = string }
variable "administrator_password" {
  type      = string
  sensitive = true
}
variable "sku_name" { type = string }
variable "storage_mb" { type = number }
variable "tags" { type = map(string) }
