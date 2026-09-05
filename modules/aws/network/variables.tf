variable "name_prefix" {
  description = "Prefix used to name networking resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name_prefix)) >= 3
    error_message = "name_prefix must contain at least three characters."
  }
}

variable "vpc_cidr" {
  description = "CIDR block used by the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones used by the network."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) > 0
    error_message = "At least one availability zone must be provided."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks used by public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) > 0 && alltrue([for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "At least one valid public subnet CIDR must be provided."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks used by private subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) > 0 && alltrue([for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "At least one valid private subnet CIDR must be provided."
  }
}

variable "common_tags" {
  description = "Tags applied to networking resources."
  type        = map(string)
  default     = {}
}
