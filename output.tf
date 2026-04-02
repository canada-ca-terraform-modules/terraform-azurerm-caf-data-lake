
output "storage_account" {
  description = "The storage account object"
  sensitive   = true
  value       = module.dlsa
}
output "data_lake_gen2_filesystem" {
  description = "The data_lake_gen2_filesystem object"
  sensitive   = true
  value       = azurerm_storage_data_lake_gen2_filesystem.filesystem
}
output "data_lake_gen2_path" {
  description = "The data_lake_gen2_path object"
  sensitive   = true
  value       = azurerm_storage_data_lake_gen2_path.paths
}
