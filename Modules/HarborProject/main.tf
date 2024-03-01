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
      n_days_since_last_pull = try(rule.value.n_days_since_last_pull, null)
      tag_matching           = try(rule.value.tag_matching, null)
      disabled               = try(rule.value.disabled, null)
      always_retain          = try(rule.value.always_retain, null)
      repo_matching          = try(rule.value.repo_matching, null)
      repo_excluding         = try(rule.value.repo_excluding, null)
      tag_excluding          = try(rule.value.tag_excluding, null)
      untagged_artifacts     = try(rule.value.untagged_artifacts, null)
      n_days_since_last_push = try(rule.value.n_days_since_last_push, null)
      most_recently_pulled   = try(rule.value.most_recently_pulled, null)
      most_recently_pushed   = try(rule.value.most_recently_pushed, null)
    }
  }
  depends_on = [harbor_project.harborproject]
}
