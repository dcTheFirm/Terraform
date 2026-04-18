# Resource Group Module
# using count so we can enable/disable creation easily

resource "azurerm_resource_group" "rg" {
  count    = var.enabled ? 1 : 0   # if true -> create, else skip

  name     = var.name
  location = var.location

  # basic timeout (in case Azure takes time)
  timeouts {
    create = var.create
    delete = var.delete
  }
}