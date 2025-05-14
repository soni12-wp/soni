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
resource "aws_s3_bucket" "main" {
  bucket = "myshayan"

  tags = {
    Name        = "My-bucket"
    Environment = "Dev"
  }
}
resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/24"

  tags = {
    name = "my-project"
  }
}
resource "aws_subnet" "new-project" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.0.0/24"  # Example CIDR block
  availability_zone = "eu-north-1c" # Example Availability Zone
  map_public_ip_on_launch = false  # Disable public IP on launch for example
  tags = {
    Name = "tf-subnet"
  }
}