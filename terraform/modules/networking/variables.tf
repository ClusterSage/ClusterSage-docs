variable "name_prefix" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "address_space" { type = list(string) }
variable "aks_subnet_prefixes" { type = list(string) }
variable "private_endpoint_subnet_prefixes" {
  type    = list(string)
  default = []
}
variable "management_subnet_prefixes" {
  type    = list(string)
  default = []
}
variable "tags" { type = map(string) }
