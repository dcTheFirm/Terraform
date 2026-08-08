#     provider "azurerm" {
#         features{}
    
#     }

#     resource "azurerm_resource_group" "rg" {
#         name = "rg-basic"
#         location = "central india"

#     }

# /*
# Create 3 subnets using One resource block and count meta-argument.
# Count keyword is used to create multiple things  of a resource.
# We can use count.index to get the current index of the resource being created. It starts with 0.

# Need to use for-each loop when we want to create multiple resources with different values. We can use count when we want to create multiple resources with same values.
# */


# resource "azurerm_virtual_network" "vnet" {
#   count               = 3
#   name                = "vnet-${count.index}" // using count.index to create unique name for each vnet.
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = [var.address_space[count.index]]
# }


# variable address_space {
#    type = list(string)    // using listof string because we are passing multiple values in the form of list.
#    default = ["10.0.0.0/16", "10.1.0.0/16", "10.2.0.0/16"]
#     }






/* FOR - EACH */

provider "azurerm" {
  features{}
}


#creating map variable
variable "env"{
    default ={ 
        dev = {
            location = "central india"
        }
        prod ={
            location = "central india"
        }
    }
    }

#creating RG using for-each with Map variable. 
resource "azurerm_resource_group" "rg" {
    for_each = var.env
    name = "rg-${each.key}"
    location = each.value.location

}


#creating storage accounts for dev and  prod 
resource "azurerm_storage_account" "st" {
  for_each = var.env

  name                     = "st${each.key}x7878ajksdf"
  resource_group_name      = azurerm_resource_group.rg[each.key].name
  location                 = azurerm_resource_group.rg[each.key].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

