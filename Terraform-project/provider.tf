terraform {
  required_providers {
    aws = {
        Source = "hashicorp/aws"
        Version = "5.94.1"
    }
    OCI = {
        Source = "Oracle/oci"
        Version = "6.35.0"
    }
  }
}

provider "aws" {
    #configuration 
}
provider "OCI" {
  #configuration
}