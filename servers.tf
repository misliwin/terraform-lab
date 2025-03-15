resource "azurerm_availability_set" "web_vm_availability_set" {
  name                         = "web_vm_availability_set-${local.name_tag}"
  location                     = azurerm_resource_group.app_rg.location
  resource_group_name          = azurerm_resource_group.app_rg.name
  managed                      = true

  # Opcje dotyczące fault domains i update domains
  platform_fault_domain_count  = 2  # Liczba fault domains (max 3 dla większości regionów)
  platform_update_domain_count = 2  # Liczba update domains (max 20 dla większości regionów)
}



# NETWORK INTERFACE #

resource "azurerm_network_interface" "nginx_nic" {
  count = var.instances_count
  name                = "nginx-nic-${local.name_tag}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name

  ip_configuration {
    name                          = "nginx-ip-config-${local.name_tag}-${count.index}"
    subnet_id                     = azurerm_subnet.dmz_subnets[count.index % var.vnet_subnet_count].id
    public_ip_address_id          = azurerm_public_ip.nginx_public_ip[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "nginx_nic_nsg" {
  count = var.instances_count
  network_interface_id      = azurerm_network_interface.nginx_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.allow_web.id
}



# VIRTUAL MACHINE #

resource "azurerm_linux_virtual_machine" "nginx_vm" {
  count = var.instances_count
  name                = "nginx-vm-${local.name_tag}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
  size                = var.VM_size
  admin_username      = local.username
  admin_password      = local.password

  network_interface_ids = [azurerm_network_interface.nginx_nic[count.index].id]

  disable_password_authentication = false  # Ustaw "false", aby umożliwić logowanie hasłem


  os_disk {
    caching              = var.vm_config.os_disk.caching
    storage_account_type = var.vm_config.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.vm_config.source_image_reference.publisher
    offer     = var.vm_config.source_image_reference.offer
    sku       = var.vm_config.source_image_reference.sku
    version   = var.vm_config.source_image_reference.version
  }

  
  custom_data = base64encode(templatefile("${path.module}/templates/startup_script.tpl", {
    instance_counter = count.index
  }))
}

/*
base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    rm /var/www/html/index.nginx-debian.html
    echo '<html><head><title>Taco Team Server</title></head><body style="background-color:#1F778D"><p style="text-align: center;"><span style="color:#FFFFFF;"><span style="font-size:28px;">Strona stworzona przez terraform przez misliwin 2</span></span></p></body></html>' | tee /var/www/html/index.html
  EOF
  )
  */

############## VM2 ###############

/*

resource "azurerm_network_interface" "nginx_nic2" {
  name                = "nginx-nic2-${local.name_tag}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name

  ip_configuration {
    name                          = "nginx2-ip-config-${local.name_tag}"
    subnet_id                     = azurerm_subnet.dmz_subnets[1].id
    public_ip_address_id          = azurerm_public_ip.nginx_public_ip2.id
    private_ip_address_allocation = "Dynamic"
  }
}



resource "azurerm_network_interface_security_group_association" "nginx_nic_nsg2" {
  network_interface_id      = azurerm_network_interface.nginx_nic2.id
  network_security_group_id = azurerm_network_security_group.allow_web.id
}


resource "azurerm_linux_virtual_machine" "nginx_vm2" {
  name                      = "nginx2-vm-${local.name_tag}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.app_rg.name
  size                      = var.VM_size
  admin_username            = local.username
  admin_password            = local.password
  availability_set_id       = azurerm_availability_set.web_vm_availability_set.id

  network_interface_ids = [azurerm_network_interface.nginx_nic2.id]

  #admin_ssh_key {
  #  username   = "mislwin"
  #  public_key = file(" /home/misliwin/.ssh/id_rsa.pub") # Zmień ścieżkę do klucza SSH
  #}
  disable_password_authentication = false  # Ustaw "false", aby umożliwić logowanie hasłem


  os_disk {
    caching              = var.vm_config.os_disk.caching
    storage_account_type = var.vm_config.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.vm_config.source_image_reference.publisher
    offer     = var.vm_config.source_image_reference.offer
    sku       = var.vm_config.source_image_reference.sku
    version   = var.vm_config.source_image_reference.version
  }

  

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    rm /var/www/html/index.nginx-debian.html
    echo '<html><head><title>Taco Team Server</title></head><body style="background-color:#1F778D"><p style="text-align: center;"><span style="color:#FFFFFF;"><span style="font-size:28px;">Strona stworzona przez terraform przez misliwin 2</span></span></p></body></html>' | tee /var/www/html/index.html
  EOF
  )
}
*/


/*
   #!/bin/bash
    apt update -y
    apt install -y nginx
    apt install -y wget curl gnupg lsb-release

    curl -sL https://aka.ms/downloadazcopy-v10-linux | tar -xz
    sudo mv ./azcopy* /azcopy /usr/local/bin/

    AZURE_STORAGE_ACCOUNT="${azurerm_storage_account.web_storage_account.name}"
    AZURE_CONTAINER_NAME="${azurerm_storage_container.web_blob_container.name}"
    AZURE_BLOB_INDEX="index.html"
    AZURE_BLOB_LOGO="Globo_logo_Vert.png"

    azcopy copy "https://$AZURE_STORAGE_ACCOUNT.blob.core.windows.net/$AZURE_CONTAINER_NAME/$AZURE_BLOB_INDEX" /home/ubuntu/index.html
    azcopy copy "https://$AZURE_STORAGE_ACCOUNT.blob.core.windows.net/$AZURE_CONTAINER_NAME/$AZURE_BLOB_LOGO" /home/ubuntu/Globo_logo_Vert.png


    systemctl start nginx
    systemctl enable nginx
    rm /var/www/html/index.nginx-debian.html
    cp /home/ubuntu/index.html /var/www/html/index.html
    cp /home/ubuntu/Globo_logo_Vert.png /var/www/html/Globo_logo_Vert.png
  EOF
*/