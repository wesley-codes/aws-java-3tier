variable "alb_sg_id" {
  description = "application load balancer id"
}


variable "public_id_subnets" {
  type        = list(string)
  description = "public id subnets"
}