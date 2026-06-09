variable "acr_name" { type = string }
variable "acr_anonymous_pull_enabled" {
  type    = bool
  default = false
}
variable "aks_name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "aks_subnet_id" { type = string }
variable "log_analytics_workspace_id" { type = string }
variable "node_count" { type = number }
variable "vm_size" { type = string }
variable "tags" { type = map(string) }
