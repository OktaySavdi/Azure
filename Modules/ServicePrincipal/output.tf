output "service_principal_name" {
  description = "The name of service principal."
  value       = azuread_service_principal.service_principal.display_name
}

output "service_principal_object_id" {
  description = "The object id of service principal."
  value       = azuread_service_principal.service_principal.id
}

output "client_id" {
  description = "The application id of AzureAD application created."
  value       = azuread_application.application.application_id
}

output "client_secret" {
  description = "Password for service principal."
  value       = azuread_application_password.application_password.value
  sensitive   = true
}

output "application_object_id" {
  description = "The object id of azure application."
  value       = azuread_application.application.object_id
}