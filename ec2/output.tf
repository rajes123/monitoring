output "public_dns" {
  value = aws_instance.terraform-ec2[*].public_dns
}

output "public_IP" {
  value = aws_instance.terraform-ec2[*].public_ip
}