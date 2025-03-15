

resource "azurerm_storage_account" "web_storage_account" {
  name                     = "webstoracmisliwin" # Nazwa konta magazynowego (musi być unikalna globalnie)
  resource_group_name       = azurerm_resource_group.app_rg.name
  location                 = var.location
  account_tier              = "Standard"
  account_replication_type = "LRS"

  # Dodanie wymaganych tagów
  tags = {
    data_classification = "cisco_public"
    intended_public     = "true"
  }
}

# Konfiguracja Blob Container w ramach Storage Account
resource "azurerm_storage_container" "web_blob_container" {
  name                  = local.azure_blob_storage_name  # Nazwa kontenera, np. 'webbucket'
  storage_account_id  = azurerm_storage_account.web_storage_account.id
  container_access_type = "blob"

}

# Wgrywanie pliku index.html do Blob Storage
resource "azurerm_storage_blob" "website" {
  name                   = "website/index.html"   # Ścieżka w kontenerze
  storage_account_name   = azurerm_storage_account.web_storage_account.name
  storage_container_name = azurerm_storage_container.web_blob_container.name
  type                   = "Block"
  source                 = "./website/index.html"

}

# Wgrywanie pliku Globo_logo_Vert.png do Blob Storage
resource "azurerm_storage_blob" "graphic" {
  name                   = "website/Globo_logo_Vert.png"  # Ścieżka w kontenerze
  storage_account_name   = azurerm_storage_account.web_storage_account.name
  storage_container_name = azurerm_storage_container.web_blob_container.name
  type                   = "Block"
  source                 = "./website/Globo_logo_Vert.png"

}

# Ustawienie polityki dostępu do obiektów (Blob Storage) - to może być specyficzne w zależności od wymagań
resource "azurerm_storage_account_network_rules" "example" {
  storage_account_id = azurerm_storage_account.web_storage_account.id

  default_action = "Allow"

  ip_rules = [
    "0.0.0.0/0"  # Możesz ustawić tutaj odpowiedni zakres IP, jeśli chcesz kontrolować dostęp
  ]
}
