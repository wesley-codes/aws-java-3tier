output "vpc_id" {
  value = aws_vpc.app_vpc.id
}

output "app_public_subnet_cidr" {
  # Return all public subnet IDs created with count
  value = aws_subnet.app_public_subnet[*].id
}

output "app_private_subnet_cidr" {
  value = aws_subnet.app_private_subnet[*].id
}

output "aws_eip" {
  value = aws_eip.nat_eip[*].public_ip
}

output "Internet_gateway" {
  value = aws_internet_gateway.app_igw.id
}

output "Nat_gateway" {
  value = aws_nat_gateway.app_nat_gateway[*].id
}

