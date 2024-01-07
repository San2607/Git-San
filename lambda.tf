data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/api"
  output_path = "${path.module}/zip/api.zip"
}

resource "aws_s3_object" "lambda" {
  bucket = var.aws_s3_bucket
  key    = "api.zip"
  source = data.archive_file.lambda.output_path
  etag   = filemd5(data.archive_file.lambda.output_path)
}

resource "aws_lambda_function" "lambda" {
  for_each         = local.routes
  function_name    = each.value.name
  s3_bucket        = var.aws_s3_bucket
  s3_key           = aws_s3_object.lambda.key
  runtime          = "nodejs14.x"
  handler          = "${each.value.name}.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  role             = aws_iam_role.lambda[each.value.name].arn
  architectures    = ["arm64"]

  environment {
    variables = {
      jwtSecret = var.jwtSecret
    }
  }
}

resource "aws_lambda_permission" "lambda" {
  for_each      = local.routes
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda[each.value.name].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "cloudwatch" {
  for_each          = local.routes
  name              = "/aws/lambda/${aws_lambda_function.lambda[each.value.name].function_name}"
  retention_in_days = 1
}
