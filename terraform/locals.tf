locals {
  name_prefix          = lower("${var.project}-${var.environment}")
  resource_name_prefix = var.resource_name_prefix != null ? var.resource_name_prefix : local.name_prefix
  tags = merge(var.tags, {
    Application = var.application_tag
    Environment = var.environment_tag != null ? var.environment_tag : var.environment
    ManagedBy   = "Terraform"
  })
}
