terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "eu-north-1"
}
locals {
  vpc_input = {
    prodvpc = "10.0.0.0/16"
  }

  }

resource "aws_vpc" "main" {
    for_each = local.vpc_input
    cidr_block = each.value

    tags = {
      Name = each.key
    }
  
}
data "aws_vpc" "main" {
    default = true
  
}
locals {
  subnet_input = {
    "eu-north-1c" = "10.0.1.0/24"
  }
}
resource "aws_subnet" "main2" {
    for_each = local.subnet_input
    availability_zone = each.key
    cidr_block = each.value
    vpc_id = data.aws_vpc.main.id

    tags = {
      Name = each.key
    }
  

}
/*locals {
  vpc_cidr = ["192.168.16.0/24" , "192.168.17.0/24"]
}
resource "aws_vpc" "main" {
  count = length(local.vpc_cidr)
  cidr_block = local.vpc_cidr[count.index]
  
  }*/

