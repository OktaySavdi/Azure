variable "public_ip" {
  description = "The list of role public_ip to this service principal"
  type = list(object({
    name                = string
    resource_group_name = string
    location            = string
    allocation_method   = string
    domain_name_label   = string
    sku                 = string
    tags                = map(string)
  }))
  default = []
}
