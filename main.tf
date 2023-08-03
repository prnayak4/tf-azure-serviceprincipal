terraform {
  #backend "remote" {}
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      #source = "hashicorp/time"
      version = "> 2.0"
    }
  }
} 

provider "azurerm" {
  skip_provider_registration = true
  features {}
}



data "azuread_client_config" "current" {}
data "azurerm_subscription" "current" {}


data "azurerm_resource_group" "rggroup" {
  name     = var.ResourceGroupName
}

resource "azurerm_storage_account" "storageacctdeploy" {
  name                     = var.StorageAcctName
  resource_group_name      = data.azurerm_resource_group.rggroup.name
  location                 = data.azurerm_resource_group.rggroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.tagname
  }
}

resource "azurerm_storage_container" "containerdeploy" {
  name                  = var.StorageContainerName 
  storage_account_name  = azurerm_storage_account.storageacctdeploy.name
  container_access_type = "private"
}

resource "azuread_application" "main" {
  display_name     =  var.service_principal_name
 /* identifier_uris  =  ["http://${var.service_principal_name}"]
  sign_in_audience = var.sign_in_audience */
  owners           = [data.azuread_client_config.current.object_id]
  
}
resource "azuread_service_principal" "main" {
  application_id    = azuread_application.main.application_id
  owners            = [data.azuread_client_config.current.object_id]
}


resource "time_rotating" "main" {
  /*rotation_rfc3339 = var.password_end_date
  rotation_years   = var.password_rotation_in_years */
  rotation_days    = var.password_rotation_in_days
 lifecycle {
    create_before_destroy = true
  }

  triggers = {
    /*end_date = var.password_end_date
    years    = var.password_rotation_in_years */
    days     = var.password_rotation_in_days

  }
}

resource "azuread_service_principal_password" "main" {
  count                = var.enable_service_principal_certificate == false ? 1 : 0
  service_principal_id = azuread_service_principal.main.object_id
  rotate_when_changed = {
    rotation = time_rotating.main.id
  }
  lifecycle {
    create_before_destroy = true
  }
}

 
resource "azurerm_role_assignment" "role_assignment_01" {
scope =data.azurerm_subscription.current.id
role_definition_name = "Reader"
principal_id = azuread_service_principal.main.object_id
}

resource "azurerm_role_assignment" "role_assignment_02" {
scope = data.azurerm_subscription.current.id
role_definition_name = "Contributor"
principal_id = azuread_service_principal.main.object_id
}

resource "azurerm_role_assignment" "role_assignment_03" {
scope = data.azurerm_subscription.current.id
role_definition_name = "Storage Blob Data Reader"
principal_id = azuread_service_principal.main.object_id
}

resource "azurerm_role_assignment" "data-contributor-role" {
  scope                = azurerm_storage_account.storageacctdeploy.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.main.object_id
}