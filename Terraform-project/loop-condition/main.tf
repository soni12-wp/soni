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
data "aws_vpc" "main" {
    default = true
}
locals {
  vpcnum = 2
  is_create = fa
}

resource "aws_vpc" "sini" {
    count = local.is_create ? local.vpcnum : 0
    cidr_block = "172.16.${count.index}.0/24"

    tags = {
      name = "mypvc-${count.index}"
    }
}
resource "aws_subnet" "sini1" {
    vpc_id = local.is_create ? aws_vpc.sini[0].id : data.aws_vpc.main.id 
    cidr_block = "172.16.2.0/24"
  
}


/* locals {
  vpcnum = 2
  is_create = true
}
resource "aws_vpc" "loop-cond" {
    count = local.is_create ? local.vpcnum : 0
    cidr_block = "172.16.${count.index}.0/24"

    tags = {
      name = "mypvc-${count.index}"
    }
  
} */

