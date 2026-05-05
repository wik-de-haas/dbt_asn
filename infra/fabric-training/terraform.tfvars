# -----------------------------------------------------------------
# General settings
# -----------------------------------------------------------------
name          = "dbt"          # <-- Leave (training name)
instance_number = 1           # <-- Leave (optional, can also be pipeline variable)
sku_name    = "F2"            # <-- Leave or override via pipeline
managed_identity_name                = "dbt-iac-identity"
managed_identity_resource_group_name = "dbt-trn-iac"

# -----------------------------------------------------------------
# Optional tags
# -----------------------------------------------------------------
custom_tags = {
  Project = "DBT Training"
  Owner   = "Trainer"
}

# -----------------------------------------------------------------
# Warehouse
# -----------------------------------------------------------------
warehouses = {
  dbt_training = {
    description = "First Warehouse for dbt training"
  }
 }
