output "vpc_id" {
  description = "ID of the lab VPC."
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the lab VPC."
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of the lab public subnets."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the lab private subnets."
  value       = module.network.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = module.network.internet_gateway_id
}
