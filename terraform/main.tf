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
}

resource "azurerm_static_web_app" "site" {
  name                = var.static_web_app_name
  resource_group_name = var.rg_name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"
}

locals {
  name     = format("<script>document.write(%s);</script><br>", join("+", [for c in split("", var.contact["name"]) : format("'%s'", c)]))
  email    = format("<script>document.write(%s);</script><br>", join("+", [for c in split("", var.contact["email"]) : format("'%s'", c)]))
  phone    = format("<script>document.write(%s);</script><br>", join("+", [for c in split("", var.contact["phone"]) : format("'%s'", c)]))
  location = format("<script>document.write(%s);</script><br>", join("+", [for c in split("", var.contact["location"]) : format("'%s'", c)]))
}

resource "null_resource" "prepare_website" {
  triggers = {
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
