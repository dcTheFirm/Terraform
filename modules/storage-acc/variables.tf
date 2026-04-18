variable "st_name" {}
variable "rg_name" {}
variable "location" {}

variable "enabled" {
  default = true
}

variable "create" {
  default = "30m"
}

variable "delete" {
  default = "30m"
}