resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "app_vpc"
  }
}


//IGW
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app_vpc"
  }
}


resource "aws_subnet" "public_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index) # change last octet per subnet
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

}

# //NAT_GW
# resource "aws_nat_gateway" "app_natgw" {

# }



