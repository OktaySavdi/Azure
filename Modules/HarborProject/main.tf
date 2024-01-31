resource "harbor_project" "harborproject" {
  name                   = var.harbor_project_name.name
  public                 = var.harbor_project_name.public
  vulnerability_scanning = var.harbor_project_name.vulnerability_scanning # (Optional) Default vale is true. Automatically scan images on push
  enable_content_trust   = var.harbor_project_name.enable_content_trust   # (Optional) Default vale is false. Deny unsigned images from being pulled
  storage_quota          = var.storage_quota == null ? "5" : var.storage_quota
}

resource "harbor_project_member_group" "harborprojectmembergroup" {
  count         = length(var.define_group)
  project_id    = harbor_project.harborproject.id
  type          = var.define_group[count.index].type
  group_name    = var.define_group[count.index].group_name
  role          = var.define_group[count.index].role
  ldap_group_dn = var.define_group[count.index].ldap_group_dn

  depends_on = [harbor_project.harborproject]
}

resource "harbor_retention_policy" "main" {
  count = length(var.image_retention_policy)

  scope    = harbor_project.harborproject.id
  schedule = var.image_retention_policy[count.index].schedule

  dynamic "rule" {
    for_each = var.image_retention_policy
    content {
      n_days_since_last_pull = var.image_retention_policy[count.index].n_days_since_last_pull
      tag_matching           = var.image_retention_policy[count.index].tag_matching
      disabled               = var.image_retention_policy[count.index].disabled
      always_retain          = var.image_retention_policy[count.index].always_retain
      repo_matching          = var.image_retention_policy[count.index].repo_matching
      repo_excluding         = var.image_retention_policy[count.index].repo_excluding
      tag_excluding          = var.image_retention_policy[count.index].tag_excluding
      untagged_artifacts     = var.image_retention_policy[count.index].untagged_artifacts
    }
  }

  depends_on = [harbor_project.harborproject]
}
