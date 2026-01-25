provider "aws" {
  region = var.region

  # Skip certain API checks for faster initialization
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = false
}
