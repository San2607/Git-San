resource "aws_apigatewayv2_api" "api" {
  name          = "questions"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins  = ["*"]
    allow_methods  = ["*"]
    allow_headers  = ["*"]
    expose_headers = ["*"]
  }
}


resource "aws_apigatewayv2_stage" "apigateway" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each           = local.routes
  api_id             = aws_apigatewayv2_api.api.id
  integration_uri    = aws_lambda_function.lambda[each.value.name].invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda["index"].id}"
}

resource "aws_apigatewayv2_route" "lambda" {
  for_each  = local.routes
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "${each.value.http_verb} ${each.value.path}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda[each.value.name].id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.api.name}"
  retention_in_days = 1
}

