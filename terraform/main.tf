resource "azurerm_storage_account" "web_storage" {
  name                             = var.sa_name
  resource_group_name              = var.rg_name
  location                         = var.storage_account_location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  allow_nested_items_to_be_public  = false
  min_tls_version                  = "TLS1_2"
  shared_access_key_enabled        = true
  cross_tenant_replication_enabled = false
  allowed_copy_scope               = "All"

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 2
    }
  }

  sas_policy {
    expiration_period = "7.00:00:00"
  }

  lifecycle {
    prevent_destroy = true
  }

  # The Terraform backend uses Microsoft-managed encryption to avoid the cost
  # and operational overhead of customer-managed keys.
  # checkov:skip=CKV2_AZURE_1: Backend storage uses Microsoft-managed encryption.
  # The backend is accessed by Azure-hosted CI and therefore cannot use a
  # private endpoint in this low-cost setup.
  # checkov:skip=CKV2_AZURE_33: Private endpoint is not configured for the backend.
  # Terraform's azurerm backend requires shared-key authentication here.
  # checkov:skip=CKV2_AZURE_40: Shared-key access is required by the Terraform backend.
  # LRS is sufficient for this personal project's recoverable state account.
  # checkov:skip=CKV_AZURE_206: LRS replication is intentional for cost control.
  # Queue logging is not used by this storage account.
  # checkov:skip=CKV_AZURE_33: Queue logging is not used by the Terraform backend.
  # Anonymous blob access is disabled above; this skip covers Checkov's broad
  # storage-account public-access rule for a backend used by authenticated CI.
  # checkov:skip=CKV_AZURE_59: Backend blobs are accessed only by authenticated CI.
}

resource "azurerm_static_web_app" "site" {
  name                = var.static_web_app_name
  resource_group_name = var.rg_name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"
}

resource "azurerm_static_web_app_custom_domain" "www" {
  static_web_app_id = azurerm_static_web_app.site.id
  domain_name       = "www.${var.custom_domain}"
  validation_type   = "dns-txt-token"

  depends_on = [azurerm_dns_cname_record.www]
}

resource "azurerm_static_web_app_custom_domain" "apex" {
  static_web_app_id = azurerm_static_web_app.site.id
  domain_name       = var.custom_domain
  validation_type   = "dns-txt-token"

  depends_on = [azurerm_dns_a_record.apex]
}

locals {
  name     = format("<script>document.write(%s);</script><br>", join("+", [for c in split("", var.contact["name"]) : format("'%s'", c)]))
  email    = format("<script>document.write(%s);</script><br>", join("+", [for c in split("", var.contact["email"]) : format("'%s'", c)]))
  phone    = format("<script>document.write(%s);</script><br>", join("+", [for c in split("", var.contact["phone"]) : format("'%s'", c)]))
  location = format("<script>document.write(%s);</script><br>", join("+", [for c in split("", var.contact["location"]) : format("'%s'", c)]))
}

resource "null_resource" "prepare_website" {
  triggers = {
    always_run    = timestamp()
    contact       = jsonencode(var.contact)
    template_hash = filesha256("${path.module}/../html/index.template.html")
  }

  provisioner "local-exec" {
    command     = <<-EOT
      sed -e "s|NAME|${local.name}|g" \
        -e "s|EMAIL|${local.email}|g" \
        -e "s|PHONE|${local.phone}|g" \
        -e "s|LOCATION|${local.location}|g" \
        ../html/index.template.html > ../html/index.html
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
