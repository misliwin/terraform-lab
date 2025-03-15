
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.7.0"
    }
  }

  backend "azurerm" {
    resource_group_name   = "Terraform-storage-account-RG"
    storage_account_name  = "tfsamisliwin"
    container_name        = "terraform-state-misliwin"
    key                   = "terraform.tfstate"
    subscription_id       = "df5fd655-d63c-4ed8-8542-2ec6c39845f2"
    tenant_id             = "5ae1af62-9505-4097-a69a-c1553ef7840e"
    #access_key            = var.azure_storage_account_key
  }
}




##################################################################################
# DATA
##################################################################################

data "template_file" "startup_file" {
  template = file(var.ftd_startup_file)
}

#data "azurerm_public_ip" "ftdv-mgmt-interface" {
#  name                = azurerm_public_ip.ftdv-mgmt-interface.name
#  resource_group_name = azurerm_virtual_machine.ftdv-instance.resource_group_name
#}


##################################################################################
# RESOURCES
##################################################################################

# RESOURCE GROUP #

resource "azurerm_resource_group" "app_rg" {
  name     = "MyRG-${local.name_tag}"
  location = var.location
}

