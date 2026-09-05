output "vpc_id" {
  description = "ID of the lab VPC when the network is deployed."
  value       = var.deploy_network ? module.network[0].vpc_id : null
}

output "vpc_cidr" {
  description = "CIDR block of the lab VPC when the network is deployed."
  value       = var.deploy_network ? module.network[0].vpc_cidr : null
}

output "public_subnet_ids" {
  description = "IDs of the lab public subnets when the network is deployed."
  value       = var.deploy_network ? module.network[0].public_subnet_ids : []
}

output "private_subnet_ids" {
  description = "IDs of the lab private subnets when the network is deployed."
  value       = var.deploy_network ? module.network[0].private_subnet_ids : []
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway when the network is deployed."
  value       = var.deploy_network ? module.network[0].internet_gateway_id : null
}
