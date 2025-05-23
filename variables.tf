##################################################################################
# Global
##################################################################################



variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "misliwin-company"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
  default = "terraform-project"
}

variable "billing_code" {
  type        = string
  description = "Billing code for resource tagging"
  default = "default-billing-code"
}

variable "company_tag" {
  type = string
  description = "My tag to names"
  default = "misliwin"
}

variable "location" {
  type        = string
  description = "base location"
  default     = "Poland Central"
}

variable "environment" {
  type = string
  description = "which env is it"
  default = "ACC"
}

##################################################################################
# Counts
##################################################################################

variable "vnet_subnet_count" {
  type        = number
  description = "Number of subnets"
  default     = 3
}

variable "ftd_int_count" {
  type        = number
  description = "Number of subnets"
  default     = 4
}

variable "instances_count" {
  type        = number
  description = "Number of servers"
  default     = 4
}

##################################################################################
# Network
##################################################################################


variable "vnet_address_space" {
  type        = list(string)
  description = "Base Address Space for VNET"
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_space" {
  type        = list(string)
  description = "Base Address Space for VNET"
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}
#[for subnet in range(var.vnet_subnet_count): cidrsubnet(var.vnet_address_space[0], 8, subnet)]

variable "ftd_address_space" {
  type        = list(string)
  description = "Base Address Space for VNET"
  default     = ["10.0.251.0/24", "10.0.252.0/24", "10.0.253.0/24", "10.0.254.0/24", "10.0.255.0/24", "10.0.250.0/24"]
}


#variable "mgmt_address_space" {
#  type        = list(string)
#  description = "Base Address Space for VNET"
#  default     = ["10.0.1.0/24"]
#}
#
#variable "diagnostic_address_space" {
#  type        = list(string)
#  description = "Base Address Space for VNET"
#  default     = ["10.0.2.0/24"]
#}
#
#variable "outside_address_space" {
#  type        = list(string)
#  description = "Base Address Space for VNET"
#  default     = ["10.0.3.0/24"]
#}
#
#variable "inside_address_space" {
#  type        = list(string)
#  description = "Base Address Space for VNET"
#  default     = ["10.0.4.0/24"]
#}


##################################################################################
# VM
##################################################################################



variable "VM_size" {
  type        = string
  description = "standard VM size"
  default     = "Standard_B1s"
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





##################################################################################
# Cisco VM FTD
##################################################################################

variable "ftd1_config" {
  description = "Configuration for the FTDv"
  type = object({
    plan = object({
      name              = string
      publisher         = string
      product           = string
    })
    storage_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    storage_os_disk = object({
      name                = string
      caching             = string
      create_option       = string
      managed_disk_type   = string
    })
    os_profile = object({
      admin_username      = string
      admin_password      = string
      computer_name       = string
      custom_data         = string
    })
    os_profile_linux_config = object({
      disable_password_authentication = bool
    })
  })

  default = {
    plan =  {
      name = "ftdv-azure-byol"
      publisher = "cisco"
      product = "cisco-ftdv"
    }
    storage_image_reference = {
      publisher = "cisco"
      offer     = "cisco-ftdv"
      sku       = "ftdv-azure-byol"
      version   = "77.0.16"
    }
    storage_os_disk = {
      name              = "myosdisk"
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Standard_LRS"
    }
    os_profile = {
      admin_username = "cisco"
      admin_password = "P@$$w0rd1234"
      computer_name  = "FTD01"
      custom_data = ""
    }
    os_profile_linux_config = {
      disable_password_authentication = false
    }

  }
}






variable "ftd_startup_file" {
  type    = string
  description = "file name of startup config for FTD"
  default = "ftd_startup_file.txt"
}

variable "prefix" {
  type    = string
  default = "cisco-ftdv"
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