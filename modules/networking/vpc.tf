resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name       = "app_vpc"
    enviroment = "vpc_${var.env}"
  }
}


//IGW
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    name       = "app_igw"
    enviroment = "igw_${var.env}"

  }
}


resource "aws_subnet" "app_public_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index) # change last octet per subnet
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {

    enviroment = "public_subnet_${var.env}"

  }

}


resource "aws_subnet" "app_private_subnet" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index + var.az_count)
  tags = {

    enviroment = "private_subnet_${var.env}"

  }
}

# Create an Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  tags = {

    enviroment = "Elastic_ip_${var.env}"

  }
}





