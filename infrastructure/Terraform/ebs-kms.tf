resource "aws_kms_key" "ebs_custom_key" {
  policy = file("iam-policy/ebs-key-policy.json")
}

resource "aws_kms_alias" "a" {
  name          = "alias/ebs-key"
  target_key_id = aws_kms_key.ebs_custom_key.key_id
}

resource "aws_iam_role" "ebs_role" {
  name = "ebs_role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ebs.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
}
EOF
}

resource "aws_kms_grant" "grant_access_ebs" {
  name              = "grant_access_ebs"
  key_id            = aws_kms_key.ebs_custom_key.key_id
  grantee_principal = aws_iam_role.ebs_role.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]

}

resource "aws_ebs_default_kms_key" "kms_key_ebs_attach" {
key_arn = aws_kms_key.ebs_custom_key.arn
}