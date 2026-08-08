variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-app-demo"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}