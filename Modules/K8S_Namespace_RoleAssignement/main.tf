# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE DEFAULT RBAC ROLES
# This defines four default RBAC roles scoped to the namespace:
# - namespace-access-all : Admin level permissions on all resources in the namespace.
# - namespace-access-read-only: Read only permissions on all resources in the namespace.
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_role" "rbac_role_access_all" {
  count = var.environment == "nonprod" ? 1 : 0

  metadata {
    name      = "${var.namespace}-access-all"
    namespace = var.namespace
    labels    = var.labels
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role" "rbac_role_access_read_only" {
  count = var.environment == "prod" ? 1 : 0

  metadata {
    name      = "${var.namespace}-access-read-only"
    namespace = var.namespace
    labels    = var.labels
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# BIND THE PROVIDED ROLES TO THE SERVICE ACCOUNT
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_role_binding_v1" "group_role_binding" {

  metadata {
    name      = "${var.namespace}-role-binding"
    namespace = var.namespace
    labels    = var.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = var.environment == "nonprod" ? "${var.namespace}-access-all" : "${var.namespace}-access-read-only"
  }

  # Users
  dynamic "subject" {
    for_each = var.assign_group.users

    content {
      kind      = "User"
      name      = subject.value
      api_group = "rbac.authorization.k8s.io"
    }
  }

  # Groups
  dynamic "subject" {
    for_each = var.assign_group.groups
    content {
      name      = subject.value
      namespace = var.namespace
      kind      = "Group"
      api_group = "rbac.authorization.k8s.io"
    }
  }
}