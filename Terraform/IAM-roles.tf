resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda to access AWS resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sqs:SendMessage", "sqs:ReceiveMessage"]
        Effect   = "Allow"
        Resource = aws_sqs_queue.notification_queue.arn
      },
      {
        Action   = ["sns:Publish"]
        Effect   = "Allow"
        Resource = aws_sns_topic.notification_topic.arn
      },
      {
        # Lambda needs permissions to send traces to X-Ray. Modify the IAM policy:
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        # SES requires IAM permissions for Lambda to send emails.
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        # lambda needs permissions to write to dynamodb
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.my_table.arn
      },
      {
        # lambda need perms to read from the queue - SQS
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.notification_queue.arn
      },
      {
        Effect   = "Allow"
        Action   = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# allow CW to log
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "cloudwatch_policy"
  description = "Policy to allow Lambda logging"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}


