locals {
  name_prefix = lower("${var.project}-${var.environment}")
  tags = merge(var.tags, {
    Application = "ClusterSage"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}
