variable "name" {}

output "printname" {
  value = "Hello, ${var.name}"
}