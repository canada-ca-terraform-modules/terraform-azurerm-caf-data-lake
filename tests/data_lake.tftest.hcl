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

run "default_values" {
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
    error_message = "Filesystem name must match the map key"
  }
}

run "filesystem_with_ace" {
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
        fs-ace = {
          owner = null
          group = null
          ace = {
            entry1 = {
              scope       = "access"
              type        = "user"
              id          = "00000000-0000-0000-0000-000000000001"
              permissions = "rwx"
            }
            entry2 = {
              scope       = "default"
              type        = "group"
              id          = "00000000-0000-0000-0000-000000000002"
              permissions = "r-x"
            }
          }
          storage_data_lake_gen2_path = {
            path1 = {
              name = "secure"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_storage_data_lake_gen2_filesystem.filesystem["fs-ace"].ace) == 2
    error_message = "Expected 2 ACE entries on filesystem"
  }
}

run "path_with_ace" {
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
            pathA = {
              name  = "dir-a"
              owner = null
              group = null
              ace = {
                e1 = {
                  scope       = "access"
                  type        = "other"
                  permissions = "r--"
                }
              }
            }
          }
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_storage_data_lake_gen2_path.paths["fs1-pathA"].ace) == 1
    error_message = "Expected 1 ACE entry on path"
  }
}
