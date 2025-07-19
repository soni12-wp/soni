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
data "aws_vpc" "existing_vpc" {
  id = "vpc-07082110c2c86e16f"
}
data "aws_internet_gateway" "existing_igw" {
  internet_gateway_id = "igw-08b1242dac7a67d3d"
}
data "aws_security_group" "existing_sg" {
id = "sg-07d541efebb4806fb"
}
resource "aws_subnet" "public_subnet" {
  vpc_id     = data.aws_vpc.existing_vpc.id
  cidr_block = "172.31.0.0/20"
  availability_zone = "eu-north-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = data.aws_vpc.existing_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.existing_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_security_group" "existing_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id
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
# Create the EC2 instance
resource "aws_instance" "windows_server" {
  ami                    = "ami-0b59aaac1a4f1a3d1"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]
  tags = {
    Name = "Windows Server"
  }
}

output "public_ip" {
  value = aws_instance.windows_server.public_ip
}
variable "ssh_public_key" {
 description = "ssh key for login"
 type = string
 sensitive = true
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250610"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
resource "aws_key_pair" "login-key" {
  key_name   = "login-key"
  public_key = var.ssh_public_key
}
resource "aws_instance" "ubuntu-vm" {
  instance_type               = "t3.micro"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.login-key.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  tags = {
   name = "ubuntu Instance"
  }

}
output "print" {
  value = aws_instance.ubuntu-vm.public_ip
  description = "public ip"
}
