

# Storage Account Module
# keeping it simple but production-safe naming

resource "azurerm_storage_account" "st" {
  count = var.enabled ? 1 : 0

  name                     = var.st_name   # must be globally unique
  resource_group_name      = var.rg_name
  location                 = var.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  # optional but good practice
  allow_nested_items_to_be_public = false

  timeouts {
    create = var.create
    delete = var.delete
  }
}








  # account_tier             = "Standard"
  # account_replication_type = "LRS"