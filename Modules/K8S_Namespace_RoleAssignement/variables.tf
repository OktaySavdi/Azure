variable "environment" {
  description = "we only have two environment - nonprod and prod"
  type        = string
  default     = ""

  validation {
    condition     = contains(["nonprod", "prod"], var.environment)
    error_message = "Possible values are `nonprod` and `prod`"
  }
}

variable "namespace" {
  description = "The name of the namespace where the roles should be created."
  type        = string
}

variable "labels" {
  description = "Map of string key value pairs that can be used to organize and categorize the roles. See the Kubernetes Reference for more info (https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)."
  type        = map(string)
  default     = {}
}

variable "assign_group" {
  description = "Defines the users and groups that will be admins in the namespace."
  type = object({
    users  = list(string)
    groups = list(string)
  })

  default = {
    users  = []
    groups = []
  }
}