data "azurerm_subscription" "current" {}


resource "azurerm_monitor_action_group" "email_alert" {
  name                = "CriticalAlertsAction"
  resource_group_name = var.rg_name
  short_name          = "Critical"

  email_receiver {
    name                    = "emailtodevops"
    email_address           = var.contact.email
    use_common_alert_schema = true
  }
}

resource "azurerm_consumption_budget_subscription" "daily_budget" {
  name            = "daily-cost-budget"
  subscription_id = data.azurerm_subscription.current.id
  amount          = 1.0 # 1€
  time_grain      = "Monthly"

  time_period {
    start_date = "2025-07-01T00:00:00Z"
    end_date   = "2030-07-01T00:00:00Z"
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 100.0 # 100% of 1.0 EUR
    contact_groups = [azurerm_monitor_action_group.email_alert.id]
  }
}
