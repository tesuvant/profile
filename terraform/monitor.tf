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
    category = "AzureCdnAccessLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert" "cdn_high_traffic_alert" {
  name                = "cdn-high-traffic-alert"
  resource_group_name  = var.rg_name
  location            = var.location
  enabled             = true
  description         = "ALERT: Vault-Tec didn't prepare me for this!!!11oneone"
  severity            = 2
  frequency           = var.qj.f
  time_window        = var.qj.w

  data_source_id = azurerm_log_analytics_workspace.cdn_lawp.id

  query = <<-KQL
    AzureDiagnostics
    | where ResourceProvider == "MICROSOFT.CDN"
    | where Category == "AzureCdnAccessLog"
    | summarize RequestsCount = count() by bin(TimeGenerated, 1m)
    | where RequestsCount > ${var.qj.t}
  KQL

  trigger {
    threshold = var.qj.t
    operator = "GreaterThan"
  }

  action {
    action_group = [azurerm_monitor_action_group.email_alert.id]
  }
}
