resource "azurerm_cdn_frontdoor_firewall_policy" "main" {
  name                = replace("waf-${var.name_prefix}", "-", "")
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  enabled             = true
  mode                = "Prevention"
  tags                = var.tags

  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.1"
    action  = "Block"
  }
}
