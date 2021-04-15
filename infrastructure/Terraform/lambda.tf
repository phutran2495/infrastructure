## create policy and role

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = "${file("iam-policy/lambda-assume-policy.json")}" 
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id 
  policy = file("iam-policy/lambda-policy.json")
}

locals {
  lambda_zip_location = "lambda-python/send-email.zip"
}

# create zip file from python source file
data "archive_file" "python" {
  type = "zip"
  source_file = "lambda-python/send-email.py"
  output_path = local.lambda_zip_location
}

# create lambda function 
resource "aws_lambda_function" "send-email" {
  filename      = local.lambda_zip_location
  function_name = "send-email"
  role          = aws_iam_role.lambda_role.arn
  handler       = "send-email.notifyuser"
  source_code_hash = filebase64sha256(local.lambda_zip_location)
  runtime = "python3.7"
}

# create sns trigger to lambda
resource "aws_lambda_permission" "with_sns" {
 statement_id = "AllowExecutionFromSNS"
 action = "lambda:InvokeFunction"
 function_name = aws_lambda_function.send-email.arn
 principal = "sns.amazonaws.com"
 source_arn = aws_sns_topic.book_api_topic.arn
}