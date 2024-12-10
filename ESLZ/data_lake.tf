variable "data_lakes" {
  type = any
  default = {}
  description = "Value for data lake. This is a collection of values as defined in data_lake.tfvars"
}

module "data_lakes" {
    for_each = var.data_lakes
    source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-data-lake?ref=1.0.1"
    location= var.location
    env = var.env
    group = var.group
    project = var.project
    userDefinedString = each.key
    data_lake= each.value
    resource_groups = local.resource_groups_all
    subnets = local.subnets
    user_data = try(each.value.user_data, false) != false ? base64encode(file("${path.cwd}/${each.value.user_data}")) : null
}