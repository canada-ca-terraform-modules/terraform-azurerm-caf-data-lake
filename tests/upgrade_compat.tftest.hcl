mock_provider "azurerm" {}
mock_provider "time" {}

variables {
  resource_groups = {
    Project = {
      name     = "rg-project"
      location = "canadacentral"
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project"
    }
  }
  subnets              = {}
  private_dns_zone_ids = {}
  tags                 = {}
  env                  = "dev"
  userDefinedString    = "test"
  location             = "canadacentral"
  group                = "test"
  project              = "test"
}

# Step 1: plan the pre-upgrade deployment (no ace, minimal config)
run "baseline_plan" {
  command = plan

  variables {
    data_lake = {
      storage_account = {
        resource_group           = "Project"
        account_tier             = "Standard"
        account_replication_type = "GRS"
        is_hns_enabled           = true
      }
      storage_data_lake_gen2_filesystems = {
        fs1 = {
          storage_data_lake_gen2_path = {
            path1 = {
              name = "data"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_storage_data_lake_gen2_filesystem.filesystem["fs1"].name == "fs1"
    error_message = "Baseline plan: filesystem address must be 'azurerm_storage_data_lake_gen2_filesystem.filesystem[\"fs1\"]'"
  }

  assert {
    condition     = contains(keys(azurerm_storage_data_lake_gen2_path.paths), "fs1-path1")
    error_message = "Baseline plan: path address must be 'azurerm_storage_data_lake_gen2_path.paths[\"fs1-path1\"]'"
  }
}

# Step 2: plan with new optional args — resource addresses must not change
run "upgrade_plan_no_replacement" {
  command = plan

  variables {
    data_lake = {
      storage_account = {
        resource_group           = "Project"
        account_tier             = "Standard"
        account_replication_type = "GRS"
        is_hns_enabled           = true
      }
      storage_data_lake_gen2_filesystems = {
        fs1 = {
          # new optional args added — must not change resource address or force replacement
          default_encryption_scope = null
          properties               = null
          owner                    = null
          group                    = null
          storage_data_lake_gen2_path = {
            path1 = {
              name  = "data"
              owner = null
              group = null
            }
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_storage_data_lake_gen2_filesystem.filesystem["fs1"].name == "fs1"
    error_message = "Upgrade plan: filesystem address must not change — a change here forces resource replacement"
  }

  assert {
    condition     = contains(keys(azurerm_storage_data_lake_gen2_path.paths), "fs1-path1")
    error_message = "Upgrade plan: path address must not change — a change here forces resource replacement"
  }
}