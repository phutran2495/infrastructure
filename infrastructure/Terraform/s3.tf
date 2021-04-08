
resource "aws_s3_bucket" "s3-webapp-bucket" {
  bucket = "webapp.phu.tran"
  acl    = "private"
  force_destroy = true
  
  lifecycle {
    prevent_destroy = false
  }

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    transition {
      days          = 30
      storage_class = "STANDARD_IA" 
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}


resource "aws_s3_bucket" "codedeploy-webapp-bucket" {
  bucket = "codedeploy.phu.tran"
  acl    = "private"
  force_destroy = true
  
  lifecycle {
    prevent_destroy = false
  }

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    transition {
      days          = 30
      storage_class = "STANDARD_IA" 
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}
