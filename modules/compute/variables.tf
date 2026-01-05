variable "alb_sg_id" {
  description = "application load balancer id"
}


variable "public_id_subnets" {
  type        = list(string)
  description = "public id subnets"
}

variable "vpc_id" {
  description = "vpc id"

}


variable "instance_profile_name" {
  type        = string
  description = "Instance profile name"
}

variable "app_sg_id" {
  type        = string
  description = "App security group ID"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}


variable "private_id_subnets" {
  type        = list(string)
  description = "private id subnets"
}