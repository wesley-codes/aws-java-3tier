variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"

}

variable "availability_zones" {
  type        = list(string)
  description = "Using two availability zones"
}


variable "az_count" {
  type        = number
  description = "Number of AZ's"
}

variable "env" {
  type        = string
  description = "enviroment"
}