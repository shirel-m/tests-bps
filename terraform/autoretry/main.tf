terraform {
  required_version = ">= 0.13"
}
// test

locals {
  key1 = ["a", 10, "c"]
  key2 = "test"
}

resource "null_resource" "my-script" {
 provisioner "local-exec11" {
    command = "sleep 1"
  }
}
