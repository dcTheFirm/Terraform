variable "name" {}
variable "location" {}

# toggle switch
variable "enabled" {
  default = true
}

# timeouts
variable "create" {
  default = "30m"
}

variable "delete" {
  default = "30m"
}