terraform {
  required_providers {
    curl = {
      source = "marcofranssen/curl"
      version = "0.2.2"
    }
  }
}

provider "curl" {
  # Configuration options
}

data "curl_request" "getTodos" {
  http_method = "GET"
  uri = "https://jsonplaceholder.typicode.com/todos/1"
}

locals {
  json_data = jsondecode(data.curl_request.getTodos.response_body)
}
