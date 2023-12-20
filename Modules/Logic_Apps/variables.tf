variable "logic_app" {
  description = "The list of role assignments to this service principal"
  type = list(object({
    logic_app_name      = string
    workflow_version    = string
    workflow_schema     = string
    location            = string
    resource_group_name = string
    tags                = map(string)
  }))
  default = []
}
