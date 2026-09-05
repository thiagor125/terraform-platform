variable "name_prefix" {
  description = "Prefix used to name networking resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block used by the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones used by the network."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks used by public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks used by private subnets."
  type        = list(string)
}

variable "common_tags" {
  description = "Tags applied to networking resources."
  type        = map(string)
  default     = {}
}
