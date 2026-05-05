# =============================================================================
# outputs.tf
# =============================================================================

# Shared Fabric module outputs
output "fabric" {
  description = "All outputs supported by the Azure Fabric module."
  value       = module.fabric
  sensitive   = false
}

# Shared Resource Group
output "resource_group" {
  description = "Shared resource group details."
  value = {
    name = module.resource_group.name
    id   = module.resource_group.id
  }
}

# Shared Fabric Workspace
output "fabric_workspace_name" {
  description = "Name of the shared Fabric workspace."
  value       = module.fabric.microsoft_fabric_workspace_name
}

# Warehouses (from enriched participants)
output "warehouses" {
  description = "Warehouses created for each participant (names and descriptions)."
  value = {
    for k, v in local.enriched_participants : k => {
      name        = "${var.name}-${v.name}-wh"
      description = "Warehouse for ${v.name}"
    }
  }
}
