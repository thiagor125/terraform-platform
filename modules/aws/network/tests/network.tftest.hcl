mock_provider "aws" {}

run "creates_expected_network_layout" {
  command = plan

  variables {
    name_prefix          = "platform-test"
    vpc_cidr             = "10.20.0.0/16"
    availability_zones   = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.20.10.0/24", "10.20.11.0/24"]
    private_subnet_cidrs = ["10.20.20.0/24", "10.20.21.0/24"]
    common_tags = {
      Environment = "test"
      ManagedBy   = "Terraform"
    }
  }

  assert {
    condition     = aws_vpc.main.cidr_block == "10.20.0.0/16"
    error_message = "The VPC must use the requested CIDR block."
  }

  assert {
    condition     = length(aws_subnet.public) == 2 && length(aws_subnet.private) == 2
    error_message = "The module must create one public and one private subnet per availability zone."
  }
}
