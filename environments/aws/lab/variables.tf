variable "aws_region" {
  description = "AWS region used by the lab environment."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "terraform-enterprise-lab"
}

variable "environment" {
  description = "Environment identifier."
  type        = string
  default     = "lab"
}

variable "deploy_network" {
  description = "Controls whether the AWS lab network exists. Set to false to destroy the managed network and true to recreate it."
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "CIDR block used by the lab VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by the lab."
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks used by public subnets."
  type        = list(string)

  default = [
    "10.10.10.0/24",
    "10.10.11.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks used by private subnets."
  type        = list(string)

  default = [
    "10.10.20.0/24",
    "10.10.21.0/24"
  ]
}
