variable "name_prefix" { type = string }
variable "resource_group_name" { type = string }
variable "sku_name" { type = string }
variable "origin_host_name" { type = string }
variable "origin_host_header" { type = string }
variable "domain_name" { type = string }
variable "waf_policy_id" { type = string }
variable "tags" { type = map(string) }
