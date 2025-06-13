variable "cdn_endpoint_name" {
  description = "Azure region location"
  type        = string
}

variable "cdn_profile_name" {
  description = "Azure region location"
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

variable "sa_name" {
  description = "Storage account name"
  type        = string
}

variable "name" {
  type        = string
  description = "Name information to replace NAME placeholder"
  sensitive   = true
  default     = "Joe Average"
}

variable "phone" {
  type        = string
  description = "Phone information to replace PHONE placeholder"
  sensitive   = true
  default     = "+18 938 1013"
}

variable "location" {
  type        = string
  description = "Location information to replace LOCATION placeholder"
  sensitive   = true
  default     = "Langley, VA"
}

variable "email" {
  type        = string
  description = "Email information to replace EMAIL placeholder"
  sensitive   = true
  default     = "joe.average@foo.bar"
}
