resource "harbor_project" "harborproject" {
  name                   = var.harbor_project_name.name
  public                 = var.harbor_project_name.public
  vulnerability_scanning = true # (Optional) Default vale is true. Automatically scan images on push
  enable_content_trust   = true # (Optional) Default vale is false. Deny unsigned images from being pulled
  storage_quota          = var.storage_quota == null ? "5" : var.storage_quota
}

resource "harbor_project_member_group" "harborprojectmembergroup" {
  project_id = harbor_project.harborproject.id

  for_each      = var.define_group
  group_name    = each.value.group_name
  role          = each.value.role
  type          = "ldap"
  ldap_group_dn = each.value.ldap_group_dn
}

resource "harbor_retention_policy" "harborretentionpolicy" {
  scope    = harbor_project.harborproject.id
  schedule = var.image_retention_policy.schedule
  rule {
    disabled               = var.image_retention_policy.disabled
    n_days_since_last_pull = var.image_retention_policy.n_days_since_last_pull
    repo_matching          = "**"
    tag_matching           = var.image_retention_policy.tag_matching != null ? var.image_retention_policy.tag_matching : "*"
  }
  rule {
    disabled               = var.image_retention_policy.disabled
    n_days_since_last_push = var.image_retention_policy.n_days_since_last_push
    repo_matching          = "**"
    tag_matching           = var.image_retention_policy.tag_matching != null ? var.image_retention_policy.tag_matching : "*"
  }
}
