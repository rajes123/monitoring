output "vpc_id" {
  value = aws_vpc.terraform-custom.id
}

output "public_subnet_id" {
    value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}