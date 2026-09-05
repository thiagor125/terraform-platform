data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_s3_bucket" "terraform_state" {
  bucket = local.state_bucket_name
}
