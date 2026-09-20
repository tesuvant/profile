variable "static_web_app_name" {
  description = "Name of the Azure Static Web App"
  type        = string
}

variable "location" {
  description = "Azure Static Web Apps region"
  type        = string
}

variable "storage_account_location" {
  description = "Region of the Terraform state storage account"
  type        = string
}

variable "rg_name" {
  description = "Name of the resource group"
  type        = string
}

variable "sa_name" {
  description = "Name of the Terraform state storage account"
  type        = string
}

variable "contact" {
  type        = map(string)
  description = "Contact information with keys: name, phone, location, email"
  sensitive   = true
  default = {
    name     = "Joe Average"
    phone    = "+18 938 1013"
    location = "Langley, VA"
    email    = "joe.average@foo.bar"
  }
}
