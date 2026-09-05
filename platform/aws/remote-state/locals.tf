locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region

  state_bucket_name = "${var.project_name}-${local.account_id}-${local.region}-tfstate"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "RemoteState"
    Repository  = "terraform-enterprise-lab"
  }
}
