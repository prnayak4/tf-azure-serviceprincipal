variable "tagname" {
  description = "Tag Name e.g Dev Test Prod"
  default = "Test"
  
}
variable "ResourceGroupName" {
  type = string
  description ="Resource Group Name for Storage Account "
  default = "rg-policy-monitor"
}
variable "StorageAcctName" {
  description = "Storage Account Name in small letter "
  default = "cloudopsstrgacctecm"
}
variable "StorageContainerName" {
  description = "Storage Account Name in small letter "
  default = "compliancereportblob"
  
}
variable "service_principal_name" {
  description = "The name of the service principal"
  default     = "ECMTestSP"
}
/*
 variable "password_end_date" {
  description = "The relative duration or RFC3339 rotation timestamp after which the password expire"
  default     = "2024-08-02T07:51:07Z"
}
 



variable "password_rotation_in_years" {
  description = "Number of years to add to the base timestamp to configure the password rotation timestamp. Conflicts with password_end_date and either one is specified and not the both"
  default     = 1
}
*/
variable "password_rotation_in_days" {
  description = "Number of days to add to the base timestamp to configure the rotation timestamp. When the current time has passed the rotation timestamp, the resource will trigger recreation.Conflicts with `password_end_date`, `password_rotation_in_years` and either one must be specified, not all"
  default     = 360
}


variable "enable_service_principal_certificate" {
  description = "Manages a Certificate associated with a Service Principal within Azure Active Directory"
  default     = false
}

variable "azure_role_name" {
  description = "A unique UUID/GUID for this Role Assignment - one will be generated if not specified."
  default     = null
}

variable "azure_role_description" {
  description = "The description for this Role Assignment"
  default     = null
}
 
