# =============================================================================
# variables.tf
# Purpose: Input definitions for Academy Fabric deployment
# One shared RG, one shared workspace, multiple warehouses (one per participant)
# =============================================================================

# ---------------------------------------------------------------------------
# Workshop / Training General Settings
# ---------------------------------------------------------------------------

variable "name" {
  description = "Short name for the training or event (e.g., 'dbt', 'fabriclab')."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 50
    error_message = "Invalid name. A Valid name should have between 1 and 50 characters."
  }
}

variable "unit" {
  description = "Business unit or subscription name."
  type        = string
  default     = "sdp"

  validation {
    condition     = length(var.unit) > 0 && length(var.unit) <= 40
    error_message = "Invalid name. A Valid name should have between 1 and 40 characters."
  }
}

variable "location" {
  description = "Azure region for deployment."
  type        = string
  default     = "westeurope"

  validation {
    condition     = contains(["westeurope", "northeurope"], var.location)
    error_message = "Invalid location. Possible values are: westeurope, northeurope."
  }
}

variable "environment" {
  description = "Deployment environment (e.g., dev, tst, acc, prd)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "tst", "acc", "prd"], var.environment)
    error_message = "Invalid environment. Must be one of: dev, tst, acc, prd."
  }
}

variable "instance_number" {
  description = "Optional instance number suffix (e.g., -001)."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_number <= 999
    error_message = "Invalid instance_number. Must be 999 or lower."
  }
}

# ---------------------------------------------------------------------------
# Participants Configuration
# ---------------------------------------------------------------------------

variable "trainer_emails" {
  description = "Comma-separated list of trainer email addresses (Admins). "
  type        = string
}

variable "participant_emails" {
  description = "Comma-separated list of participant email addresses (Contributors). "
  type        = string
}


# ---------------------------------------------------------------------------
# Administration & Fabric Capacity
# ---------------------------------------------------------------------------

variable "administration_members" {
  description = "Comma-separated list of trainer/admin email addresses"
  type        = string
}

variable "sku_name" {
  description = "Fabric capacity SKU (F2, F4, F8)."
  type        = string
  default     = "F2"

  validation {
    condition     = contains(["F2", "F4", "F8"], var.sku_name)
    error_message = "Invalid sku_name. Allowed values: F2, F4, F8."
  }
}

variable "create_fabric_capacity" {
  description = "If true, creates a new Fabric capacity. Otherwise, uses existing one."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Optional / Reused Settings (unchanged)
# ---------------------------------------------------------------------------

variable "custom_tags" {
  description = "Additional tags for created resources."
  type        = map(string)
  default     = {}
}

variable "fabric_workspace_name" {
  description = "Optional explicit Fabric workspace name (used when shared)."
  type        = string
  default     = null
}

variable "managed_identity_name" {
  description = "Name of the managed identity used in the pipeline."
  type        = string
  default     = null
}

variable "managed_identity_resource_group_name" {
  description = "Resource group name of the managed identity used in the pipeline."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Warehouses
# ---------------------------------------------------------------------------
# Keep this if you still need the  static warehouses
variable "warehouses" {
  description = "Optional static warehouses that can also be deployed."
  type = map(object({
    description = optional(string)
  }))
  default = null
}
