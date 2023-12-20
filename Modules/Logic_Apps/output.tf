output "logic_app_name" {
  value = [for i in azurerm_logic_app_workflow.workflow : i.name]
}
output "logic_app_location" {
  value = [for i in azurerm_logic_app_workflow.workflow : i.location]
}
output "id" {
  value = [for i in azurerm_logic_app_workflow.workflow : i.id]
}
output "workflow_versions" {
  value = [for i in azurerm_logic_app_workflow.workflow : i.workflow_version]
}
