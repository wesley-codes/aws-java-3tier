output "vpc_id" {
  value = aws_vpc.app_vpc.id
}

output "public_subnet_cidr" {
  # Return all public subnet IDs created with count
  value = aws_subnet.public_subnet[*].id
}
