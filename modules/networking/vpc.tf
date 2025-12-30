resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.env-prefix}-vpc"
  }
}

resource "aws_subnet" "app_public_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index) # change last octet per subnet
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {

    Name = "${var.env-prefix}-public-subnet-${count.index}"

  }

}


resource "aws_subnet" "app_private_subnet" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index + var.az_count)
  tags = {

    Name = "${var.env-prefix}-private-subnet-${count.index}"

  }
}


//IGW
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "${var.env-prefix}-igw"


  }
}


# Create an Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  count  = 2
  domain = "vpc"
  tags = {

    Name = "${var.env-prefix}-Elastic_ip-${count.index}"

  }
}

#Create a NAT Gateway in a public subnet
resource "aws_nat_gateway" "app_nat_gateway" {
  count         = 2
  allocation_id = aws_eip.nat_eip[count.index].allocation_id
  subnet_id     = aws_subnet.app_public_subnet[count.index].id
  depends_on    = [aws_internet_gateway.app_igw]
  tags = {
    Name = "${var.env-prefix}-Nat-gateway-${count.index}"

  }
}

# Create a public route table
resource "aws_route_table" "app_public_route_table" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
  tags = {

    Name = "${var.env-prefix}-public-route_table"

  }

}

#Associate public subnets
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.app_public_subnet) //get the number of public subnets
  subnet_id      = aws_subnet.app_public_subnet[count.index].id
  route_table_id = aws_route_table.app_public_route_table.id
}


resource "aws_route_table" "app_private_route_table" {
  vpc_id = aws_vpc.app_vpc.id
  count  = length(aws_nat_gateway.app_nat_gateway)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app_nat_gateway[count.index].id
  }
  tags = {
    Name = "${var.env-prefix}-private-route_table"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.app_private_subnet)
  subnet_id      = aws_subnet.app_private_subnet[count.index].id
  route_table_id = aws_route_table.app_private_route_table[count.index].id

}