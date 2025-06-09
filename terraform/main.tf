# Reference the imported Storage Account resource
resource "azurerm_storage_account" "web_storage" {
  name                     = var.sa_name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Enable versioning
  blob_properties {
    versioning_enabled       = true
    delete_retention_policy {
      days = 2
    }
  }

  lifecycle {
    prevent_destroy = true   # Prevent deletion (used for tfstate too)
  }
}

# Static website config
resource "azurerm_storage_account_static_website" "static_site" {
  storage_account_id = azurerm_storage_account.web_storage.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

resource "null_resource" "upload_website" {
  provisioner "local-exec" {
    command = <<EOT
      az storage blob upload-batch \
        --account-name ${azurerm_storage_account.web_storage.name} \
        --source ../html \
        --destination '$web' \
        --auth-mode login
    EOT
  }

  depends_on = [azurerm_storage_account_static_website.static_site]
}