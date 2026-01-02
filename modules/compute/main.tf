resource "aws_lb" "app_alb" {
  name                       = "app-alb"
  load_balancer_type         = "application"
  internal                   = false
  security_groups            = [var.alb_sg_id]
  subnets                    = var.public_id_subnets
  enable_deletion_protection = false


}