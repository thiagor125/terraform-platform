terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "thiagor125"

    workspaces {
      name = "aws-lab"
    }
  }
}
