variable "rg" {
  description = "The name and location of the Resource Group"
  type = list(object({
    name                 = string
    location             = string
    tags                 = map(string)
  }))
  default = []
}
