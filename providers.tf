terraform {
  experiments = [module_variable_optional_attrs]
}

provider "aws" {
  region                  = var.aws_region
  skip_get_ec2_platforms  = true
  skip_metadata_api_check = true
  skip_region_validation  = true
}
