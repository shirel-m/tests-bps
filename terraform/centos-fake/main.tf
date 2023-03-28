provider "aws" {
  region = "us-east-1"
}

resource "null_resource" "null_resource_simple" {
  provisioner "local-exec" {
    command = "echo virtual machine name ${format("%s", var.virtual_machine_name)}"
  }
}
