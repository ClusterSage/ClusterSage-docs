locals {
  name_prefix = lower("${var.project}-${var.environment}")
  tags = merge(var.tags, {
    Application = "KubeSage"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}
