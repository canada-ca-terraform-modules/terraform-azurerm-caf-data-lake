# terraform-azurerm-caf-data-lake
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dlsa"></a> [dlsa](#module\_dlsa) | github.com/canada-ca-terraform-modules/terraform-azurerm-caf-storage_accountV2.git | v1.0.3 |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_data_lake_gen2_filesystem.filesystem](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_filesystem) | resource |
| [azurerm_storage_data_lake_gen2_path.paths](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_path) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_lake"></a> [data\_lake](#input\_data\_lake) | (Required) Cluster configuration for the HA VMs. | `any` | `null` | no |
| <a name="input_env"></a> [env](#input\_env) | (Required) 4 character string defining the environment name prefix for the VM | `string` | `"dev"` | no |
| <a name="input_group"></a> [group](#input\_group) | (Required) Character string defining the group for the target subscription | `string` | `"test"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location for the VM | `string` | `"canadacentral"` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | (Required) List of private DNS zone IDs | `any` | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | (Required) Character string defining the project for the target subscription | `string` | `"test"` | no |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | (Required) Resource group object for the VM | `any` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | (Required) List of subnet objects for the VM | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that will be applied to every associated VM resource | `map(string)` | `{}` | no |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | (Required) User defined portion value for the name of the VM. | `string` | `"test"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Base64 encoded file representing user data script for the VM | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_lake_gen2_filesystem"></a> [data\_lake\_gen2\_filesystem](#output\_data\_lake\_gen2\_filesystem) | The data\_lake\_gen2\_filesystem object |
| <a name="output_data_lake_gen2_path"></a> [data\_lake\_gen2\_path](#output\_data\_lake\_gen2\_path) | The data\_lake\_gen2\_path object |
| <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account) | The storage account object |
<!-- END_TF_DOCS -->