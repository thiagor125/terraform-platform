check "subnet_layout" {
  assert {
    condition = (
      length(var.availability_zones) == length(var.public_subnet_cidrs) &&
      length(var.availability_zones) == length(var.private_subnet_cidrs)
    )
    error_message = "Public and private subnet lists must match the number of availability zones."
  }

  assert {
    condition = length(distinct(concat(
      var.public_subnet_cidrs,
      var.private_subnet_cidrs
    ))) == length(var.public_subnet_cidrs) + length(var.private_subnet_cidrs)
    error_message = "Subnet CIDR blocks must not be duplicated."
  }
}
