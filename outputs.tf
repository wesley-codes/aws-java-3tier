output "vpc" {
  value = module.vpc.vpc_id

}

output "availability_zones" {
  value = local.azs
}

output "public_subnet_cidr" {
  value = module.vpc.app_public_subnet_cidr
}

output "private_subnet_cidr" {
  value = module.vpc.app_private_subnet_cidr
}

output "Elastic_ip" {
  value = module.vpc.aws_eip
}