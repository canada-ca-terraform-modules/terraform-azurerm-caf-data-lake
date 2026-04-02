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

  # Shared minimal data_lake config used by most runs; overridden per-run as needed
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

# ---------------------------------------------------------------------------
# Filesystem: default configuration
# ---------------------------------------------------------------------------

run "filesystem_name_matches_map_key" {
  command = plan

  assert {
    condition     = azurerm_storage_data_lake_gen2_filesystem.filesystem["fs1"].name == "fs1"
    error_message = "Filesystem name must equal the map key — used as the ADLS container identifier"
  }
}

run "filesystem_no_ace_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_storage_data_lake_gen2_filesystem.filesystem["fs1"].ace) == 0
    error_message = "ace must be empty when not provided — stale ACE entries grant unintended access"
  }
}

run "filesystem_default_encryption_scope_passthrough" {
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
          default_encryption_scope = "myencryptionscope"
          storage_data_lake_gen2_path = {
            path1 = { name = "data" }
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_storage_data_lake_gen2_filesystem.filesystem["fs1"].default_encryption_scope == "myencryptionscope"
    error_message = "default_encryption_scope must be passed through to the resource unchanged"
  }
}

# ---------------------------------------------------------------------------
# Filesystem: ACE entries
# ---------------------------------------------------------------------------

run "filesystem_ace_count" {
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
          ace = {
            entry1 = { scope = "access", type = "user", id = "00000000-0000-0000-0000-000000000001", permissions = "rwx" }
            entry2 = { scope = "default", type = "group", id = "00000000-0000-0000-0000-000000000002", permissions = "r-x" }
          }
          storage_data_lake_gen2_path = {
            path1 = { name = "secure" }
          }
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_storage_data_lake_gen2_filesystem.filesystem["fs-ace"].ace) == 2
    error_message = "Both ACE entries must be rendered — missing entries silently drop access control rules"
  }
}

run "filesystem_ace_no_entries_when_null" {
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
        fs-no-ace = {
          ace = null
          storage_data_lake_gen2_path = {
            path1 = { name = "data" }
          }
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_storage_data_lake_gen2_filesystem.filesystem["fs-no-ace"].ace) == 0
    error_message = "Explicitly null ace must produce zero ACE entries — null guard must handle explicit null, not just missing key"
  }
}

# ---------------------------------------------------------------------------
# Path: default configuration
# ---------------------------------------------------------------------------

run "path_name_and_resource_type" {
  command = plan

  assert {
    condition     = azurerm_storage_data_lake_gen2_path.paths["fs1-path1"].path == "data"
    error_message = "Path must use the 'name' field from the tfvars config as its path value"
  }

  assert {
    condition     = azurerm_storage_data_lake_gen2_path.paths["fs1-path1"].resource == "directory"
    error_message = "resource type must always be 'directory' — the provider only supports directory paths"
  }
}

run "path_no_ace_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_storage_data_lake_gen2_path.paths["fs1-path1"].ace) == 0
    error_message = "ace must be empty when not provided — stale path ACE entries grant unintended access"
  }
}

# ---------------------------------------------------------------------------
# Path: ACE entries
# ---------------------------------------------------------------------------

run "path_ace_count" {
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
                e1 = { scope = "access", type = "other", permissions = "r--" }
              }
            }
          }
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_storage_data_lake_gen2_path.paths["fs1-pathA"].ace) == 1
    error_message = "Path ACE entry must be rendered — missing entries silently drop access control rules"
  }
}

run "path_ace_no_entries_when_null" {
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
              name = "dir-a"
              ace  = null
            }
          }
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_storage_data_lake_gen2_path.paths["fs1-pathA"].ace) == 0
    error_message = "Explicitly null path ace must produce zero ACE entries — ternary null guard must handle explicit null"
  }
}

# ---------------------------------------------------------------------------
# Multi-path: composite key generation
# ---------------------------------------------------------------------------

run "multi_path_composite_keys" {
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
        fsa = {
          storage_data_lake_gen2_path = {
            p1 = { name = "alpha" }
            p2 = { name = "beta" }
          }
        }
        fsb = {
          storage_data_lake_gen2_path = {
            p1 = { name = "gamma" }
          }
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_storage_data_lake_gen2_path.paths) == 3
    error_message = "zipmap must produce one path per fs+path combination — wrong count means composite key collision or missing entries"
  }

  assert {
    condition     = contains(keys(azurerm_storage_data_lake_gen2_path.paths), "fsa-p1")
    error_message = "Composite key must follow '{fs_key}-{path_key}' pattern"
  }

  assert {
    condition     = contains(keys(azurerm_storage_data_lake_gen2_path.paths), "fsb-p1")
    error_message = "Composite key must include filesystem prefix to avoid collisions across filesystems"
  }

  assert {
    condition     = azurerm_storage_data_lake_gen2_path.paths["fsa-p1"].path == "alpha"
    error_message = "Path value must match the 'name' field from the corresponding path config"
  }
}
