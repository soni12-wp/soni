terraform {
  backend "s3" {
    bucket = "shayanbook"
    key    = "terraform.tfstate"
    region = "eu-north-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}
provider "aws" {
  region = "eu-north-1"

}
locals {
  aws_vpc_cidr = "192.168.0.0/16"

  tags = { Name = "New-Project" }
}
resource "aws_vpc" "main" {
  cidr_block           = local.aws_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.tags
}

data "aws_availability_zones" "available" {
  state = "available"

}
resource "aws_subnet" "main" {
  for_each          = toset(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.aws_vpc_cidr, 6, index(data.aws_availability_zones.available.names, each.value))
  availability_zone = each.value

}
resource "aws_internet_gateway" "internet" {
  vpc_id = local.aws_vpc_cidr
  tags   = local.tags

}
resource "aws_route_table" "table" {
  vpc_id = local.aws_vpc_cidr
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet.id
  }
  tags = local.tags

}
resource "aws_route_table_association" "main" {
  for_each       = aws_subnet.main
  subnet_id      = each.value.id
  route_table_id = aws_route_table.table.id

}
resource "aws_security_group" "security" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
resource "aws_key_pair" "ubuntu" {
  key_name   = "new-key"
  public_key = file("C:\\Users\\Administrator\\.ssh\\id_rsa.pub")
}
resource "aws_instance" "project" {
  instance_type               = "t3.micro"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.ubuntu.key_name
  subnet_id                   = values(aws_subnet.main)[0].id
  associate_public_ip_address = true

  tags = local.tags

}
output "print" {
  value = aws_instance.project.public_ip
  description = "public ip"
}