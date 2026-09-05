variable "aws_region" {
  description = "AWS region where the Terraform remote state resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Base name used to identify the project resources."
  type        = string
  default     = "terraform-enterprise-lab"
}

variable "environment" {
  description = "Environment identifier used by the bootstrap resources."
  type        = string
  default     = "shared"
}
