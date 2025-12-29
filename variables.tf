variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "az_count" {
  type        = number
  description = "Number of AZ's"
}


# variable "availability_zones" {
#   type        = list(string)
#   description = "Using two availability zones"
# }