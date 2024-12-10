module "dlsa" {
  source ="github.com/canada-ca-terraform-modules/terraform-azurerm-caf-storage_accountV2.git?ref=v1.0.3"
  userDefinedString = var.userDefinedString
  location = var.location
  env = var.env
  resource_groups = var.resource_groups
  storage_account = var.data_lake.storage_account
  subnets = var.subnets
  private_dns_zone_ids = var.private_dns_zone_ids
  tags = var.tags
}

resource "time_sleep" "wait_2_minute" {
  depends_on = [module.dlsa]

  create_duration = "2m"
}

# Create File Systems for each Data Lake Storage Account
resource "azurerm_storage_data_lake_gen2_filesystem" "filesystem" {
  for_each = var.data_lake.storage_data_lake_gen2_filesystems
  name               = each.key
  storage_account_id = module.dlsa.id
  default_encryption_scope = try(each.value.default_encryption_scope, null)
  properties =try(each.value.properties, null)
  owner = try(each.value.owner, null)
  group = try(each.value.group, null)

  dynamic "ace" {
    for_each = try(each.value.ace, null) != null ? [1] : []
    content {
      scope         = try(each.value.ace.scope, null)
      type = try(each.value.ace.type, null)
      id = try(each.value.ace.id, null)
      permissions = try(each.value.ace.permission, null)

    }
  }
  depends_on = [ time_sleep.wait_2_minute ]
}

# Create Paths within the File Systems for each Data Lake
resource "azurerm_storage_data_lake_gen2_path" "paths" {
  for_each = zipmap(
    flatten([
      for fs_key, fs_value in var.data_lake.storage_data_lake_gen2_filesystems : [
        for path_key, path_value in fs_value.storage_data_lake_gen2_path : "${fs_key}-${path_key}"
      ]
    ]),
    flatten([
    for fs_key, fs_value in var.data_lake.storage_data_lake_gen2_filesystems : [
      for path_key, path_value in fs_value.storage_data_lake_gen2_path : {
        file_system_key  = fs_key
        path_name        = path_value.name
        owner            = try(path_value.owner, null)
        group            = try(path_value.group, null)
        ace              = try(path_value.ace, null)
        storage_account_id  = module.dlsa.id
      }
    ]
  ])
  )

  path               = each.value.path_name
  filesystem_name   = azurerm_storage_data_lake_gen2_filesystem.filesystem[each.value.file_system_key].name
  storage_account_id = each.value.storage_account_id
  resource           = "directory"

  owner = each.value.owner
  group = each.value.group
  dynamic "ace" {
    for_each = try(each.value.ace, null) != null ? [1] : []
    content {
      scope         = try(each.value.ace.scope, null)
      type = try(each.value.ace.type, null)
      id = try(each.value.ace.id, null)
      permissions = try(each.value.ace.permission, null)

    }
  }

  depends_on = [ azurerm_storage_data_lake_gen2_filesystem.filesystem ]
}




