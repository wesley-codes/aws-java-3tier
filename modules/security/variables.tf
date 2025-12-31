variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
}

variable "app_port" {
  type = number

}

variable "db_port" {
  type = number

}

variable "env-prefix" {
  type        = string
  description = "enviroment"
  default     = "dev"
}