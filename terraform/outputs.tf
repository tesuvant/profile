output "static_web_app_name" {
  description = "Name used by the Static Web Apps deployment command"
  value       = azurerm_static_web_app.site.name
}

output "static_web_app_default_hostname" {
  description = "Azure-provided hostname for DNS configuration"
  value       = azurerm_static_web_app.site.default_host_name
}
