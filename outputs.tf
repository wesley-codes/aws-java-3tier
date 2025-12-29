output "vpc" {
  value = module.vpc.vpc_id

}

output "availability_zones" {
  value = local.azs
}

output "public_subnet_cidr" {
  value = module.vpc.public_subnet_cidr
}
