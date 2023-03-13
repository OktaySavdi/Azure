data "harbor_project" "main" {
    name    = var.harbor_project_name
}

resource "harbor_project_member_group" "harborprojectmembergroup" {
  project_id = data.harbor_project.main.id

  for_each      = var.define_group
  group_name    = each.value.group_name
  role          = each.value.role
  type          = "ldap"
  ldap_group_dn = each.value.ldap_group_dn
}
