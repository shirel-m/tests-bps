provider "curl" {
}

data "curl" "getTodos" {
  http_method = "GET"
  uri = "https://jsonplaceholder.typicode.com/todos/1"
}

locals {
  json_data = jsondecode(data.curl.getTodos.response)
}