output "name" {
  description = "The name of the created namespace."
  value       = element(concat(kubernetes_namespace.namespace.*.id, [""]), 0)
}

output "rbac_access_all_role" {
  description = "The name of the RBAC role that grants admin level permissions on the namespace."
  value = element(
    concat(kubernetes_role.rbac_role_access_all.*.metadata.0.name, [""]),
    0,
  )
}

output "rbac_access_read_only_role" {
  description = "The name of the RBAC role that grants read only permissions on the namespace."
  value = element(
    concat(
      kubernetes_role.rbac_role_access_read_only.*.metadata.0.name,
      [""],
    ),
    0,
  )
}