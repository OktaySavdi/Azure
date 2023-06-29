data "harbor_project" "main" {
    name    = var.harbor_project_name
}

resource "harbor_project_member_group" "harborprojectmembergroup" {
  project_id = data.harbor_project.main.id

  count         = length(var.define_group)
  type          = "ldap"
  group_name    = var.define_group[count.index].group_name
  role          = var.define_group[count.index].role
  ldap_group_dn = var.define_group[count.index].ldap_group_dn
}
