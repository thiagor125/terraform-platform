variable "hcp_organization" {
  description = "Name of the HCP Terraform organization to create/use."
  type        = string
}

variable "hcp_project" {
  description = "HCP Terraform project name."
  type        = string
  default     = "terraform-lab"
}

variable "hcp_workspace" {
  description = "HCP Terraform workspace name for the AWS lab."
  type        = string
  default     = "aws-lab"
}

variable "admin_email" {
  description = "Email used for the HCP Terraform organization."
  type        = string
}

variable "project_name" {
  description = "Base name used for AWS IAM resources."
  type        = string
  default     = "terraform-enterprise-lab"
}

variable "aws_region" {
  description = "AWS region used by the lab."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Local AWS CLI profile used only for bootstrap."
  type        = string
  default     = "terraform-lab"
}
