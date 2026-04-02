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
    error_message = "Baseline plan: filesystem name must be 'fs1'"
  }
}

# Step 2: plan with new optional args added — resource addresses must not change
run "upgrade_plan_no_replacement" {
  command = plan

  variables {
    data_lake = {
      storage_account = {
        resource_group           = "Project"
        account_tier             = "Standard"
        account_replication_type = "GRS"
        is_hns_enabled           = true
        # new optional arg — must not trigger replacement
        default_to_oauth_authentication = false
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
    error_message = "Upgrade plan: filesystem address must not have changed"
  }
}