variable "subnet_name" {}
variable "rg_name" {}
variable "vnet_name" {}

variable "address_prefixes" {
  type = list(string)
}

variable "enabled" {
  default = true
}

variable "nsg_id" {}