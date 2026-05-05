# =============================================================================
# dbt Training (Shared) - One Capacity, One Workspace, Multiple Warehouses
# =============================================================================


# -----------------------------------------------------------
# Shared Resource Group
# -----------------------------------------------------------
module "resource_group" {
  source  = "terralist.valcon.com/valcon-iac/resource-group/azure"
  version = "~> 1.0"

  name                                    = "rg-${var.name}-${var.environment}"  # training name
  unit                                    = var.unit        # business unit or team code
  location                                = var.location    # Azure region
  environment                             = var.environment # deployment environment
}


# # -----------------------------------------------------------
# # Lookup Azure AD Object IDs and names for all participants
# # -----------------------------------------------------------
data "azuread_user" "participants" {
  for_each = local.participants
  user_principal_name = each.value.email
}


# -----------------------------------------------------------
# Local transformations
# -----------------------------------------------------------
locals {
  # Build participants from DevOps UI inputs (emails only)
  trainer_list     = split(",", replace(var.trainer_emails, " ", ""))
  participant_list = split(",", replace(var.participant_emails, " ", ""))

  # Unified participants map keyed by email with standardized roles
  participants = merge(
    { for email in local.trainer_list     : email => { email = email, role = "Admin" } },
    { for email in local.participant_list : email => { email = email, role = "Contributor" } }
  )
  # Convert comma-separated admin emails (pipeline variable) into a list
  administration_members = split(",", replace(var.administration_members, " ", ""))

  # Enrich participants with live Entra (Azure AD) data (name/id)
  enriched_participants = {
    for key, user in data.azuread_user.participants :
    key => {
      name      = user.display_name      # pulled automatically from Entra ID
      email     = user.mail
      object_id = user.id
      role      = local.participants[key].role
    }
  }
}

# ---------------------------------------------------------------------------
# Wait for the Fabric workspace to be fully registered before creating warehouses. This resolves potential timing issues.
# ---------------------------------------------------------------------------
resource "time_sleep" "wait_for_workspace" {
  depends_on      = [module.resource_group]
  create_duration = "45s"
}

# -----------------------------------------------------------
# Shared Fabric Capacity + One Workspace + Multiple Warehouses
# -----------------------------------------------------------
module "fabric" {
  source  = "terralist.valcon.com/valcon-iac/fabric/azure"
  version = "~> 0.6"


  # Single shared workspace and capacity for everyone
  name        = var.name
  unit        = var.unit
  location    = var.location
  environment = var.environment

  # Attach to the single resource group
  resource_group = module.resource_group

  administration_members = local.administration_members
  instance_number        = var.instance_number
  sku_name               = var.sku_name
  custom_tags            = var.custom_tags

  # Create one warehouse per participant
  # Each warehouse name can be derived from the participant key or name
  warehouses = {
    for k, v in local.enriched_participants : v.name => {
      name        = "${var.name}-${v.name}-wh"
      description = "Warehouse for ${v.name}"
    }
  }

  # -----------------------------------------------------------
  # Role Assignments per participant
  # -----------------------------------------------------------
  role_assignments = {
    for k, v in local.enriched_participants : v.email => {
      type      = "User"
      role      = v.role
      object_id = v.object_id
    }
  }

  create_fabric_capacity = var.create_fabric_capacity
  fabric_workspace_name  = "${var.name}-ws"

  managed_identity_name                = var.managed_identity_name
  managed_identity_resource_group_name = var.managed_identity_resource_group_name

  depends_on = [time_sleep.wait_for_workspace] # Ensure solving timing issues
}
