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
  source                = "./modules/compute"
  alb_sg_id             = module.security.alb_sg_id
  public_id_subnets     = module.vpc.app_public_subnet_cidr
  vpc_id                = module.vpc.vpc_id
  availability_zone     = local.azs[0]
  instance_type         = var.instance_type
  instance_profile_name = module.security.iam_instance_profile_ec2_profile
  app_sg_id             = module.security.app_sg_id
  private_id_subnets    = module.vpc.app_private_subnet_cidr
}
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}
