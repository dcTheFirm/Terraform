variable "resource_group_name" {
  default = "prod-lb-rg"
}

variable "location" {
  default = "central india"
}

variable "admin_username" {
  type = string
  default = "azureuser"
}

variable "admin_password" {
  description = "VM admin password"
  sensitive   = true  
  default = null   // Set to null to avoid hardcoding sensitive information like psswrd . 
}