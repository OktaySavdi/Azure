### Data sources ###
data "azurerm_key_vault" "kv" {
  name                = "<keyvault_name>"
  resource_group_name = "<resourcegroup_name>"
}

data "azurerm_key_vault_secret" "ansible_api_token" {
  name         = "tmc-svc-token"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "api_token" {
  name         = "tmc-api-token"
  key_vault_id = data.azurerm_key_vault.kv.id
}

### Providers ###
provider "tanzu-mission-control" {
  endpoint            = "mycompany.tmc.cloud.vmware.com"
  vmw_cloud_api_token = data.azurerm_key_vault_secret.api_token.value
}

### TKC Cluster creation
resource "tanzu-mission-control_cluster" "create_tkgs_workload" {
  management_cluster_name = var.management_cluster_name
  provisioner_name        = var.provisioner_name
  name                    = var.cluster_name

  meta {
    labels = var.labels
  }

  spec {
    cluster_group = var.cluster_group
    tkg_service_vsphere {
      settings {
        network {
          pods {
            cidr_blocks = [
              var.pods_cidr_blocks,
            ]
          }
          services {
            cidr_blocks = [
              var.services_cidr_blocks,
            ]
          }
        }
      }

      distribution {
        version = var.k8s_version
      }

      topology {
        control_plane {
          class             = var.control_plane_class
          storage_class     = var.storage_class
          high_availability = var.control_plane_high_availability
        }
        node_pools {
          spec {
            worker_node_count = var.worker_node_count
            node_label        = var.labels

            tkg_service_vsphere {
              class         = var.worker_node_class
              storage_class = var.storage_class
            }
          }
          info {
            name        = var.nodepool_name
            description = var.nodepool_description
          }
        }
      }
    }
  }
}

### Commvault integration
resource "null_resource" "call-ansible-commvault-api-job" {
  provisioner "local-exec" {
    command = <<EOT
  curl -f -k -H 'Content-Type: application/json' -XPOST -d '{"extra_vars": "{\"commvault_env\": \"${var.environment}\", \"cluster_name\": \"${var.cluster_name}\", \"supervisor_ns\": \"${var.provisioner_name}\" }"}' --user 'svc_hce_tmc:${data.azurerm_key_vault_secret.ansible_api_token.value}' https://ansible.com/api/v2/job_templates/1/launch/
EOT
  }

  depends_on = [tanzu-mission-control_cluster.create_tkgs_workload]
}

### DNS integration
resource "null_resource" "call-ansible-dns-api-job" {
  provisioner "local-exec" {
    command = <<EOT
  curl -f -k -H 'Content-Type: application/json' -XPOST -d '{"extra_vars": "{\"commvault_env\": \"${var.environment}\", \"cluster_name\": \"${var.cluster_name}\", \"supervisor_ns\": \"${var.provisioner_name}\" }"}' --user 'svc_hce_tmc:${data.azurerm_key_vault_secret.ansible_api_token.value}' https://ansible.com/api/v2/job_templates/2/launch/
EOT
  }

  depends_on = [tanzu-mission-control_cluster.create_tkgs_workload]
}
