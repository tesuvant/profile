variable "location" {
  description = "Azure region location"
  type        = string
  default = "northeurope"
}

variable "rg_name" {
  description = "Name of the resource group"
  type        = string
  default = "profile"
}

variable "sa_name" {
  description = "Storage account name"
  type        = string
  default = "827be54aprofile"
}
