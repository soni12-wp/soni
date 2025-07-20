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
variable "ssh_private_key" "privatekey" {
    name = "privatekey"
    description = "login on ubuntu server"
}
resource "null_resource" "remotelogin" {

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "echo "This is Nginx server on ubuntu" > /var/www/html/index.html",
    ]

    connection {
      type = "ssh"
      host = "13.53.188.17" # Replace with the server's IP or hostname
      user = "ubuntu" # Replace with your username
      private_key = var.ssh_private_key.remotelogin.key_name # Replace with your private key path
      # Or, if using a password:
      # password = "your_password"
    }
  }
}