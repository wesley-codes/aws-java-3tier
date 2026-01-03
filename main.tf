data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source             = "./modules/networking/"
  vpc_cidr_block     = var.vpc_cidr_block
  availability_zones = local.azs
  az_count           = var.az_count

}

module "security" {
  source   = "./modules/security"
  vpc_id   = module.vpc.vpc_id
  app_port = var.app_port
  db_port  = var.db_port
}


module "compute" {
  source            = "./modules/compute"
  alb_sg_id         = module.security.alb_sg_id
  public_id_subnets = module.vpc.app_public_subnet_cidr
  vpc_id            = module.vpc.vpc_id
}
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}
