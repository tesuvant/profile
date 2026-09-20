resource "azurerm_dns_zone" "site" {
  name                = var.custom_domain
  resource_group_name = var.rg_name
}

resource "azurerm_dns_cname_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.site.name
  resource_group_name = var.rg_name
  ttl                 = 300
  record              = azurerm_static_web_app.site.default_host_name
}

resource "azurerm_dns_a_record" "apex" {
  name                = "@"
  zone_name           = azurerm_dns_zone.site.name
  resource_group_name = var.rg_name
  ttl                 = 300
  target_resource_id  = azurerm_static_web_app.site.id
}

resource "azurerm_dns_txt_record" "apex_validation" {
  name                = "_dnsauth"
  zone_name           = azurerm_dns_zone.site.name
  resource_group_name = var.rg_name
  ttl                 = 300

  record {
    value = azurerm_static_web_app_custom_domain.apex.validation_token
  }
}
