resource "azurerm_dns_zone" "my_domain" {
  name                = var.custom_domain
  resource_group_name = var.rg_name
}

resource "azurerm_dns_cname_record" "cdn_www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.my_domain.name
  resource_group_name = var.rg_name
  ttl                 = 300
  target_resource_id  = azurerm_cdn_endpoint.cdn_endpoint.id
}
