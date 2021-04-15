
provider "aws" {
    region = var.AWS_REGION
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
      Name = "csye6225-vpc"
  }
}

resource "aws_subnet" "main-public-1" {
  vpc_id  = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "csye6225-main-public-1"
  }
}

resource "aws_subnet" "main-public-2" {
  vpc_id  = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    Name = "csye6225-main-public-2"
  }
}

resource "aws_subnet" "main-public-3" {
  vpc_id  = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1c"
  tags = {
    Name = "csye6225-main-public-3"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "csye-route-table"
  }
}

resource "aws_route_table_association" "custom-rt-association-1" {

  route_table_id = aws_route_table.r.id

  subnet_id = aws_subnet.main-public-1.id

}

resource "aws_route_table_association" "custom-rt-association-2" {

  route_table_id = aws_route_table.r.id

  subnet_id = aws_subnet.main-public-2.id

}

resource "aws_route_table_association" "custom-rt-association-3" {

  route_table_id = aws_route_table.r.id

  subnet_id = aws_subnet.main-public-3.id

}

resource "aws_security_group" "application" {
  name        = "app-security-group"
  vpc_id      = aws_vpc.main.id

   
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}














