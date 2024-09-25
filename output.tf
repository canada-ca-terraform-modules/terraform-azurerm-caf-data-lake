
output "storage_account" {
  description = "The storage account object"
  value       = module.dlsa
}
output "data_lake_gen2_filesystem" {
  description = "The data_lake_gen2_filesystem object"
  value       = azurerm_storage_data_lake_gen2_filesystem.filesystem
}
output "data_lake_gen2_path" {
  description = "The data_lake_gen2_path object"
  value       = azurerm_storage_data_lake_gen2_path.paths
}
