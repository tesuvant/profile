variable "static_web_app_name" {
  description = "Name of the Azure Static Web App"
  type        = string
}

variable "custom_domain" {
  description = "The custom domain name"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "rg_name" {
  description = "Name of the resource group"
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
