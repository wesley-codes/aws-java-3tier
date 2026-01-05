resource "aws_lb" "app_alb" {
  name                       = "app-alb"
  load_balancer_type         = "application"
  internal                   = false
  security_groups            = [var.alb_sg_id]
  subnets                    = var.public_id_subnets
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"
  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "app-target-group"
  }
}


data "aws_ami" "Ubuntu_Server_22_image" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "app-server-launch-template" {
  name = "app-server-launch-template"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_options {
    core_count       = 4
    threads_per_core = 2
  }

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_stop        = true
  disable_api_termination = true

  ebs_optimized = true

  iam_instance_profile {
    name = var.instance_profile_name
  }

  image_id = data.aws_ami.Ubuntu_Server_22_image.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_market_options {
    market_type = "spot"
  }
  instance_type = var.instance_type

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
  }
  placement {
    availability_zone = var.availability_zone
  }

  vpc_security_group_ids = ["${var.app_sg_id}"]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  # user_data = filebase64("${path.module}/example.sh")
}



resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-asg"
  max_size                  = 2
  min_size                  = 2
  vpc_zone_identifier       = var.private_id_subnets
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.lb_target_group.arn]
  
  launch_template {
    id      = aws_launch_template.app-server-launch-template.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "app-server"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}