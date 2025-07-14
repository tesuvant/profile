resource "azurerm_log_analytics_workspace" "cdn_lawp" {
  name                = "${var.rg_name}-cdn-lawp"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "cdn_diag" {
  name                       = "cdn-endpoint-logs"
  target_resource_id         = azurerm_cdn_profile.cdn_profile.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.cdn_lawp.id
  enabled_log {
    category = "ClientRequestLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_metric_alert" "high_traffic_alert" {
  name                = "cdn-high-traffic"
  resource_group_name = var.rg_name
  scopes              = [azurerm_cdn_endpoint.cdn_endpoint.id]
  description         = "ALERT: Vault-Tec didn’t prepare me for this!!!11oneone"
  severity            = 2
  frequency           = var.qj.f
  window_size         = var.qj.w
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Cdn/profiles/endpoints"
    metric_name      = "RequestCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.qj.t
  }
}
