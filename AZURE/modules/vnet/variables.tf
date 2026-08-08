variable "vnet_name" {}
variable "location" {}
variable "rg_name" {}

variable "address_space" {
  type = list(string)
}

variable "enabled" {
  default = true
}

variable "create" {
  default = "30m"
}

variable "delete" {
  default = "30m"
}