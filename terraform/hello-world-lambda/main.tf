# require provideres block
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>4.0"            
        }
    }  
}

provider "aws" {
  region = var.aws_region
}

# allows using data attributes of current AWS account
data "aws_caller_identity" "current" {}

# Retrieve details of existing S3 bucket by name
data "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket_name
}

# Random name suffix
resource "random_pet" "lambda_bucket_name" {
  length = 4
}

# Zip source code into zip file
data "archive_file" "lambda_hello_world_zip" {
  type = "zip"

  source_dir  = "${path.module}/hello-world"
  output_path = "${path.module}/hello-world.zip"
}

## Watch for changes in ZIP SHA - used as a watcher for updated in the lambda sources
resource "null_resource" "sha_change_checker" {
  triggers = {
    src_hash = "${data.archive_file.lambda_hello_world_zip.output_sha}"
  }

  provisioner "local-exec" {
    command = "echo Changes discovered in lambda code"
  }
}

# Upload Lambda code archive from runner to S3 
resource "aws_s3_object" "lambda_hello_world_code_file" {
  bucket = data.aws_s3_bucket.lambda_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_hello_world_zip.output_path

  etag = filemd5(data.archive_file.lambda_hello_world_zip.output_path)
}

# AWS Lambda function to execute JS code as API endpoint 
resource "aws_lambda_function" "hello_world" {
  function_name = "HelloWorld-${random_pet.lambda_bucket_name.id}"

  s3_bucket = data.aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello_world_code_file.key

  runtime = "nodejs16.x"
  handler = "hello.handler"

  source_code_hash = data.archive_file.lambda_hello_world_zip.output_base64sha256

  role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.lambda_iam_role}"
}

# # Lambda function log group
# resource "aws_cloudwatch_log_group" "hello_world_log_group" {
#   name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"

#   retention_in_days = 30
# }

# Lambda API Endpoint Type
resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw-${random_pet.lambda_bucket_name.id}"
  protocol_type = "HTTP"
}

# Lambda api gateway log group
# resource "aws_cloudwatch_log_group" "hello_world_api_gw_log_Group" {
#   name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

#   retention_in_days = 30
# }

# Lambda execution stage
resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage-${random_pet.lambda_bucket_name.id}"
  auto_deploy = true

#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.hello_world_api_gw_log_Group.arn

#     format = jsonencode({
#       requestId               = "$context.requestId"
#       sourceIp                = "$context.identity.sourceIp"
#       requestTime             = "$context.requestTime"
#       protocol                = "$context.protocol"
#       httpMethod              = "$context.httpMethod"
#       resourcePath            = "$context.resourcePath"
#       routeKey                = "$context.routeKey"
#       status                  = "$context.status"
#       responseLength          = "$context.responseLength"
#       integrationErrorMessage = "$context.integrationErrorMessage"
#       }
#     )
#   }
}

# Integrate the function as a POST endpoint
resource "aws_apigatewayv2_integration" "hello_world_func_integration" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.hello_world.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Route incoming GET requests to the lambda function
resource "aws_apigatewayv2_route" "hello_world" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.hello_world_func_integration.id}"
}

# Allow AWS to call the function
resource "aws_lambda_permission" "hello_world_func_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
