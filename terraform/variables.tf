variable "cdn_endpoint_name" {
  description = "Azure region location"
  type        = string
}

variable "cdn_profile_name" {
  description = "Azure region location"
  type        = string
}

variable "contact" {
  type = string
  description = "Multiline contact info to replace CONTACT placeholder"
  sensitive = true
  default = "Joe Average"
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

variable "sa_name" {
  description = "Storage account name"
  type        = string
}
