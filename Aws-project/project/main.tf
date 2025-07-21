

  terraform {
  backend "s3" {
    bucket = "myshayan"
    key    = "terraform.tfstate"
    region = "eu-north-1"
  }
  }
terraform {
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
variable "ssh_private_key" {
 description = "ssh key for login"
 type = string
 sensitive = true
}
resource "null_resource" "remotelogin" {

  provisioner "remote-exec" {
    inline = [
      "sudo apt install nginx -y",
      "sudo systemctl start nginx"
    ]

    connection {
      type = "ssh"
      host = "13.53.188.17" # Replace with the server's IP or hostname
      user = "ubuntu" # Replace with your username
      private_key = var.ssh_private_key # Replace with your private key path
      # Or, if using a password:
      # password = "your_password"
    }
  }
}