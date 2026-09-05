module "network" {
  source = "git::https://github.com/thiagor125/terraform-platform.git//modules/aws/network?ref=7b1d505c5ae8278b1709de0bd2fd1a619b894fa1"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  common_tags          = local.common_tags
}
