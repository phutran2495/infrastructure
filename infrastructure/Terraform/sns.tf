
resource "aws_iam_role" "sns_role" {
 name = "sns-role"
 assume_role_policy = jsonencode({
 "Version": "2012-10-17",
 "Statement": {
 "Effect": "Allow",
 "Principal": {"Service": "sns.amazonaws.com"},
 "Action": "sts:AssumeRole"
 }
 })
}

resource "aws_iam_role_policy" "sns_cloudwatch_policy" {
 name = "sns_cloudwatch_policy"
 role = aws_iam_role.sns_role.id
 policy = <<-EOF
  {
  "Version": "2012-10-17",
  "Statement": [
  {
  "Effect": "Allow",
  "Action": [
  "logs:CreateLogGroup",
  "logs:CreateLogStream",
  "logs:PutLogEvents",
  "logs:PutMetricFilter",
  "logs:PutRetentionPolicy"
  ],
  "Resource": [
  "*"
  ]
  }
  ]
  }
  EOF
  
}

resource "aws_iam_role_policy_attachment" "AWSCloudWatchRole4" {
 policy_arn =  "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
 role = aws_iam_role.sns_role.id
}
 
resource "aws_iam_role_policy_attachment" "lambda_role" {
 policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
 role = aws_iam_role.sns_role.id
}
 
resource "aws_iam_role_policy_attachment" "sns_role" {
 policy_arn =  "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
 role = aws_iam_role.sns_role.id
}

resource "aws_sns_topic" "book_api_topic" {
 name = "book_api_topic"
 lambda_success_feedback_role_arn = aws_iam_role.sns_role.arn
 lambda_failure_feedback_role_arn = aws_iam_role.sns_role.arn
}

resource "aws_sns_topic_policy" "sns_policy" {
 arn = aws_sns_topic.book_api_topic.arn
 policy = <<EOF
  {
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
  {
  "Sid": "__default_statement_ID",
  "Effect": "Allow",
  "Principal": {
  "AWS": "*"
  },
  "Action": [
  "SNS:Publish",
  "SNS:RemovePermission",
  "SNS:SetTopicAttributes",
  "SNS:DeleteTopic",
  "SNS:ListSubscriptionsByTopic",
  "SNS:GetTopicAttributes",
  "SNS:Receive",
  "SNS:AddPermission",
  "SNS:Subscribe"
  ],
  "Resource": "arn:aws:sns:us-east-1:709891834787:",
  "Condition": {
  "StringEquals": {
  "AWS:SourceOwner": "709891834787" 
  }
  }
  },
  {
  "Sid": "__console_pub_0",
  "Effect": "Allow",
  "Principal": {
  "AWS": "*"
  },
  "Action": "SNS:Publish",
  "Resource": "arn:aws:sns:us-east-1:709891834787:"
  },
  {
  "Sid": "__console_sub_0",
  "Effect": "Allow",
  "Principal": {
  "AWS": "*"
  },
  "Action": [
  "SNS:Subscribe",
  "SNS:Receive"
  ],
  "Resource": "arn:aws:sns:us-east-1:709891834787:"
  }
  ]
  }
  EOF
}

resource "aws_sns_topic_subscription" "sns-topic" {
  topic_arn = aws_sns_topic.book_api_topic.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.send-email.arn
}

