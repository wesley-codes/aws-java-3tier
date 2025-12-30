data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source             = "./modules/networking/"
  vpc_cidr_block     = var.vpc_cidr_block
  availability_zones = local.azs
  az_count           = var.az_count

}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}