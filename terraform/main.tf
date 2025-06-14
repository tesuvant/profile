# Reference the imported Storage Account resource
resource "azurerm_storage_account" "web_storage" {
  name                             = var.sa_name
  resource_group_name              = var.rg_name
  location                         = var.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  allow_nested_items_to_be_public  = false
  min_tls_version                  = "TLS1_2"
  shared_access_key_enabled        = true
  cross_tenant_replication_enabled = false

  # Enable versioning
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 2
    }
  }

  lifecycle {
    prevent_destroy = true # Prevent deletion (used for tfstate too)
  }

  # FIX: Add sas_policy to enforce SAS expiration
  sas_policy {
    expiration_period = "7.00:00:00" # SAS tokens expire after 7 days by default
  }

  # checkov:skip=CKV_AZURE_33: "Ensure Storage logging is enabled for Queue service for read, write and delete requests - deliberately disabled due to FinOps ;) "
  # checkov:skip=CKV_AZURE_59: "Public access (anonymous read for $web container) is required for static website hosting."
  # checkov:skip=CKV_AZURE_206: "Ensure that Storage Accounts use replication - LRS deliberately chosen for cost optimization in personal project"
  # checkov:skip=CKV_AZURE_190: "Public access for blobs is required for static website hosting ($web container)."
  # checkov:skip=CKV2_AZURE_1: "Customer-Managed Keys not enabled due to increased cost and complexity for personal project (Microsoft-Managed Keys are sufficient)."
  # checkov:skip=CKV2_AZURE_33: "Private Endpoint not configured as public access is required for static website hosting."
  # checkov:skip=CKV2_AZURE_40: "Shared Key access is required for specific legacy/local authentication (e.g., Terraform backend) where AAD isn't fully integrated yet."
  # checkov:skip=CKV2_AZURE_47: "Anonymous blob access is required for public static website hosting ($web container)."
}

# Static website config
resource "azurerm_storage_account_static_website" "static_site" {
  storage_account_id = azurerm_storage_account.web_storage.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

locals {
  name     = format("<script>document.write(%s);</script>", join("+", [for c in split("", var.contact["name"]) : format("'%s'", c)]))
  email    = format("<script>document.write(%s);</script>", join("+", [for c in split("", var.contact["email"]) : format("'%s'", c)]))
  phone    = format("<script>document.write(%s);</script>", join("+", [for c in split("", var.contact["phone"]) : format("'%s'", c)]))
  location = format("<script>document.write(%s);</script>", join("+", [for c in split("", var.contact["location"]) : format("'%s'", c)]))
}

resource "null_resource" "upload_website" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command     = <<EOT
      sed -e "s|NAME|${local.name}|g" \
        -e "s|EMAIL|${local.email}|g" \
        -e "s|PHONE|${local.phone}|g" \
        -e "s|LOCATION|${local.location}|g" \
        ../html/index.template.html > ../html/index.html
      rm -f ../html/index.template.html
      az storage blob upload-batch \
        --account-name ${azurerm_storage_account.web_storage.name} \
        --source ../html \
        --destination '$web' \
        --auth-mode login \
        --content-cache-control "no-cache, no-store, must-revalidate" \
        --overwrite
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [azurerm_storage_account_static_website.static_site]
}

resource "azurerm_cdn_profile" "cdn_profile" {
  name                = var.cdn_profile_name
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  name                = "${var.cdn_endpoint_name}${var.sa_name}"
  profile_name        = azurerm_cdn_profile.cdn_profile.name
  resource_group_name = var.rg_name
  location            = var.location

  origin_host_header = "${var.sa_name}.z16.web.core.windows.net"
  is_http_allowed    = true
  is_https_allowed   = true

  origin {
    name      = "staticwebsite"
    host_name = "${var.sa_name}.z16.web.core.windows.net"
  }

  # Redirect: HTTP --> HTTPS
  delivery_rule {
    name  = "EnforceHTTPS"
    order = "1"

    request_scheme_condition {
      operator     = "Equal"
      match_values = ["HTTP"]
    }

    url_redirect_action {
      redirect_type = "Found"
      protocol      = "Https"
    }
  }

  depends_on = [azurerm_storage_account_static_website.static_site]
  # checkov:skip=CKV_AZURE_197: HTTP is allowed for debugging or legacy clients
}

resource "azurerm_cdn_endpoint_custom_domain" "custom_domain" {
  cdn_endpoint_id = azurerm_cdn_endpoint.cdn_endpoint.id
  name            = replace(var.custom_domain, ".", "-")
  host_name       = var.custom_domain

  cdn_managed_https {
    certificate_type = "Dedicated"
    protocol_type    = "ServerNameIndication"
    tls_version      = "TLS12"
  }
}
