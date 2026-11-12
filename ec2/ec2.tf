resource "aws_key_pair" "terraform-key" {
  key_name = "terraform-key"
  public_key = file("./terraform-key.pub")
}


resource "aws_default_vpc" "default" {
  
}

resource "aws_security_group" "terraform-sg" {
  vpc_id = aws_default_vpc.default.id
  name = "terraform-sg"
  tags = {
    "Name" = "terraform-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh" {
    security_group_id = aws_security_group.terraform-sg.id
    to_port = 22
    from_port = 22
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.terraform-sg.id
  to_port = 80
  from_port = 80
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow-all" {
  security_group_id = aws_security_group.terraform-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_instance" "terraform-ec2" {
  
  key_name = aws_key_pair.terraform-key.key_name
  security_groups = [ aws_security_group.terraform-sg.name ]
  ami = "ami-0c7632fb77f35db43"
  count = 1
  instance_type = "t2.micro"
  user_data =  file("install_nginx.sh")
  root_block_device {
    volume_size = 16
    volume_type = "gp3"
    delete_on_termination = true
  }
  tags = {
    name = "terraform-ec2"
    envorment = "dev"
  }
}

provider "aws" {
  region = "ap-south-1"
}

