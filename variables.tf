variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "az_count" {
  type        = number
  description = "Number of AZ's"
}

variable "app_port" {
  type = number
}

variable "db_port" {
  type = number

}
