data "azurerm_subscription" "current" {}

resource "azurerm_consumption_budget_subscription" "daily_budget" {
  name            = "daily-cost-budget"
  subscription_id = data.azurerm_subscription.current
  amount          = 0.5 # 0.5€
  time_grain      = "Daily"

  time_period {
    start_date = "2025-07-01T00:00:00Z"
    end_date   = "2030-07-01T00:00:00Z"
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 100.0 # 100% of 0.5 EUR
    contact_emails = [var.contact.email]
    contact_groups = [azurerm_monitor_action_group.email_alert.id]
  }
}
