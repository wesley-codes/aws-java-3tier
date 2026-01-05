output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}


output "iam_instance_profile_ec2_profile" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "app_sg_id" {
  value = aws_security_group.app_sg.id
}