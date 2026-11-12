
resource "aws_vpc" "terraform-custom" {

    
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
      Name = "terraform-demo"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.terraform-custom.id
    cidr_block = "10.0.1.0/24"

    tags = {
      Name = "public-subnet"
    }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.terraform-custom.id
    cidr_block = "10.0.2.0/24"

    tags = {
     Name = "private-subnet"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.terraform-custom.id
    tags = {
      Name = "terraform-igw"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.terraform-custom.id
    tags = {
      Name = "public-route-table"
    }
}

resource "aws_route" "internet" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

