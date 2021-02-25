
provider "aws" {
    region = "us-east-1"
  }
    

variable "ssh_key_name" {
    type = string
    default = "csye6225"
}

resource "aws_vpc" "vpc123" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_classiclink_dns_support = true
  tags = {
      Name = "csye6225-vpc"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id  = aws_vpc.vpc123.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "csye6225-subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id  = aws_vpc.vpc123.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "csye6225-subnet2"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id  = aws_vpc.vpc123.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "csye6225-subnet3"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc123.id
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.vpc123.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "csye-igw"
  }
}

resource "aws_route_table_association" "custom-rt-association-1" {

  provider = aws

  route_table_id = aws_route_table.r.id

  subnet_id = aws_subnet.subnet1.id

}

resource "aws_route_table_association" "custom-rt-association-2" {

  provider = aws

  route_table_id = aws_route_table.r.id

  subnet_id = aws_subnet.subnet2.id

}

resource "aws_route_table_association" "custom-rt-association-3" {

  provider = aws

  route_table_id = aws_route_table.r.id

  subnet_id = aws_subnet.subnet3.id

}