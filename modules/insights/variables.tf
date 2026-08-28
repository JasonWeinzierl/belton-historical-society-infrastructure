variable "environment" {
  description = "The non-abbreviated environment name."
  type        = string
}

variable "location" {
  description = "The geographic region in Azure."
  type        = string
}

variable "resource_group_name" {
  description = "The Azure resource group name."
  type        = string
}

variable "client_origins" {
  description = "The browser origins allowed to submit client telemetry through API Management."
  type        = set(string)
}

variable "publisher_email" {
  description = "The API Management publisher email address."
  type        = string
}
