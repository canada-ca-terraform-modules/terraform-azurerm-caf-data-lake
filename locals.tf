locals {
  resource_group_name = strcontains(var.data_lake.storage_account.resource_group, "/resourceGroups/") ? regex("[^\\/]+$", var.data_lake.storage_account.resource_group) :  var.resource_groups[var.data_lake.storage_account.resource_group].name
}