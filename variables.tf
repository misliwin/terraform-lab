##################################################################################
# Global
##################################################################################


variable "storage_account_resource_group_name" {
  type    = string
  description = "resource group for storage account"
  default = "Terraform-storage-account-RG"
}

variable "tfstate_storage_account_name" {
  type    = string
  description = "Storage account name"
  default = "tfsamisliwin"
}

variable "tfstate_container_name" {
  type    = string
  description = "container in storage account for tfstate"
  default = "terraform-state-misliwin"
}

variable "tfstate_key" {
  type    = string
  default = "terraform.tfstate"
  description = "Name of tfstate file"
}

variable "subscription_id" {
  type    = string
  default = "df5fd655-d63c-4ed8-8542-2ec6c39845f2"
}

variable "tenant_id" {
  type    = string
  default = "5ae1af62-9505-4097-a69a-c1553ef7840e"
}


##################################################################################
# Cisco VM FTD
##################################################################################

variable "ftd_startup_file" {
  type    = string
  description = "file name of startup config for FTD"
  default = "ftd_startup_file.txt"
}

variable "prefix" {
  type    = string
  default = "cisco-ftdv"
}



#variable "azure_storage_account_key" {
#  type    = string
#  description = "Access key to storage acount"
#}


variable "company_tag" {
  type = string
  description = "My tag to names"
  default = "misliwin"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Base Address Space for VNET"
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_space" {
  type        = list(string)
  description = "Base Address Space for VNET"
  default     = ["10.0.0.0/24"]
}

variable "location" {
  type        = string
  description = "base location"
  default     = "Poland Central"
}

variable "standard_source_image_reference" {
  description = "Standard VM"
  type = map(string)
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "standard_os_disk" {
  description = "Standard Disk"
  type = map(string)
  default = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

variable "vm_config" {
  description = "Configuration for the VM including OS disk and image reference"
  type = object({
    os_disk = object({
      caching              = string
      storage_account_type = string
    })
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
  })
  default = {
    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }
    source_image_reference = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    }
  }
}



variable "source-address" {
  type    = string
  default = "*"
}
variable "IPAddressPrefix" {
  default = "10.10"
}
variable "Version" {
  default = "77.0.16"
}
variable "VMSize" {
  default = "Standard_D3_v2"
}
variable "RGName" {
  default = "cisco-ftdv-RG"
}
variable "instancename" {
  default = "FTD01"
}
variable "username" {
  default = "cisco"
}
variable "password" {
  default = "P@$$w0rd1234"
  sensitive = true
}