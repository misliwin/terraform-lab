variable "prefix" {
  type    = string
  default = "cisco-ftdv"
}

variable "azure_storage_account_key" {
  type    = string
  description = "Access key to storage acount"
}


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