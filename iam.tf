resource "aws_iam_role" "lambda" {
  for_each = local.routes
  name     = "questions-${var.aws_region}-${each.value.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Sid       = ""
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  for_each = local.routes

  name = "lambda-${each.value.name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid : "logs",
        Effect : "Allow",
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource : "arn:aws:logs:*:*:*"
      },
      {
        Effect : "Allow",
        Action : each.value.policies,
        Resource : each.value.resource,
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "permissions" {
  for_each   = local.routes
  policy_arn = aws_iam_policy.lambda_policy[each.value.name].arn
  role       = aws_iam_role.lambda[each.value.name].name
}
