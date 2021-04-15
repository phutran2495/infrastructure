resource "aws_kms_key" "rds_custom_key" {
    policy = file("iam-policy/rds-key-policy.json")
}

resource "aws_kms_alias" "rds_alias" {
  name          = "alias/rds"
  target_key_id = aws_kms_key.rds_custom_key.key_id
}

resource "aws_iam_role" "rds_role" {
    name = "rds-role"

     assume_role_policy = file("iam-policy/rds-role.json")
}

resource "aws_kms_grant" "grant_access_rds" {
  name              = "grant_access_rds"
  key_id            = aws_kms_key.rds_custom_key.key_id
  grantee_principal = aws_iam_role.rds_role.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]

}