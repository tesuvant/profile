resource "azurerm_dns_zone" "my_domain" {
  name                = var.custom_domain
  resource_group_name = var.rg_name
}

resource "azurerm_dns_cname_record" "cdn_alias" {
  name                = "www" # or "" for apex/root if using alias record (Azure doesn't support CNAME at root)
  zone_name           = azurerm_dns_zone.my_domain.name
  resource_group_name = var.rg_name
  ttl                 = 3600
  record              = "${azurerm_cdn_endpoint.cdn_endpoint.name}.azureedge.net"
}
