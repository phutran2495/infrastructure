
provider "aws" {
    region = var.AWS_REGION
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
      Name = "csye6225-vpc"
  }
}

resource "aws_subnet" "main-public-1" {
  vpc_id  = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "csye6225-main-public-1"
  }
}

resource "aws_subnet" "main_public-2" {
  vpc_id  = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    Name = "csye6225-main_public-2"
  }
}

resource "aws_subnet" "main-public-3" {
  vpc_id  = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1c"
  tags = {
    Name = "csye6225-main-public-3"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "csye-route-table"
  }
}

resource "aws_route_table_association" "custom-rt-association-1" {

  route_table_id = aws_route_table.r.id

  subnet_id = aws_subnet.main-public-1.id

}

resource "aws_route_table_association" "custom-rt-association-2" {

  route_table_id = aws_route_table.r.id

  subnet_id = aws_subnet.main_public-2.id

}

resource "aws_route_table_association" "custom-rt-association-3" {

  route_table_id = aws_route_table.r.id

  subnet_id = aws_subnet.main-public-3.id

}

resource "aws_security_group" "application" {
  name        = "app-security-group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "database" {
  name        = "database-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups   = ["${aws_security_group.application.id}"]
  }

    ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups  = ["${aws_security_group.application.id}"]
  }

 
}


resource "aws_db_subnet_group" "database-sn" {
  name = "main"
  subnet_ids =[aws_subnet.main_public-2.id, aws_subnet.main-public-3.id]
}


resource "aws_db_instance" "mysql" {
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "csye6225"
  identifier           = "csye6225"
  username             = "csye6225"
  password             = "Edward123"
  parameter_group_name = "default.mysql5.7"
  multi_az             = false
  publicly_accessible  = true
  vpc_security_group_ids=[aws_security_group.database.id]
  db_subnet_group_name = aws_db_subnet_group.database-sn.name
  allocated_storage       = 5
  skip_final_snapshot     = true
  apply_immediately       = true
  tags = {
    Name = "MySql"
  }
}


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


####################################################
resource "aws_iam_role" "CodeDeployServiceRole" {
  name               = "CodeDeployServiceRole"
  assume_role_policy = file("codedeploy-assume.json")
}

# 12. Create IAM Policy    
resource "aws_iam_policy" "CodeDeployPolicy" {
  name        = "CodeDeployPolicy"
  policy      = file("codedeploy-policy.json")
}

# 13. Attach policy to role created
resource "aws_iam_role_policy_attachment" "codedeploy-ec2-attach" {
  role       = aws_iam_role.CodeDeployServiceRole.name
  policy_arn = aws_iam_policy.CodeDeployPolicy.arn
}

##########################################################



resource "aws_codedeploy_app" "csye6225-webapp" {
  compute_platform = "Server"
  name             = "csye6225-webapp"
}


resource "aws_codedeploy_deployment_group" "csye6225-deployment-group" {
  app_name               = aws_codedeploy_app.csye6225-webapp.name
  deployment_group_name  = "csye6225-webapp-deployment"
  service_role_arn       = aws_iam_role.CodeDeployServiceRole.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_style {
    deployment_type = "IN_PLACE"
  }

  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = "cicd"
  }

  auto_rollback_configuration {
    enabled = false
  }

}

# 11. Create IAM Role
resource "aws_iam_role" "ec2-role" {
  name               = "ec2-role"
  description        = "IAM role for webapp ec2 instance"
  assume_role_policy = file("ec2-assume-policy.json")
}

# 12. Create IAM Policy    
resource "aws_iam_policy" "s3-policy" {
  name        = "s3-policy"
  description = "Policy to allow services to access S3 bucket"
  policy      = file("s3-cloudwatch-policy.json")
}

# 13. Attach policy to role created
resource "aws_iam_role_policy_attachment" "iam-s3-attach" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.s3-policy.arn
}

# 14. Create IAM instance profile to link role with EC2 instance
resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-access-s3-codedeploy"
  role = aws_iam_role.ec2-role.name
}

resource "aws_key_pair" "csyekeypair" {
  key_name = "csye6225keypair"
  public_key = "${file("~/csyekeypair.pub")}"
}


resource "aws_instance" "webapp"{
  ami                         = var.AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main-public-1.id
  depends_on                  = [aws_db_instance.mysql]
  vpc_security_group_ids      = [aws_security_group.application.id]
  key_name                    = aws_key_pair.csyekeypair.key_name
  associate_public_ip_address = true
  root_block_device  {
    volume_size                = 20
    volume_type                = "gp2"
    delete_on_termination      = true
  }
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
  user_data            = <<-EOF
                          #!/bin/bash
                          sudo echo "#!/bin/bash" > /etc/profile.d/envvars.sh
                          sudo echo "export dbusername=${var.DB_USERNAME} ">> /etc/profile.d/envvars.sh
                          sudo echo "export dbpassword=${var.DB_PASSWORD} ">> /etc/profile.d/envvars.sh
                          sudo echo "export bucketname=${var.BUCKETNAME} ">> /etc/profile.d/envvars.sh
                          sudo echo "export dbendpoint=${aws_db_instance.mysql.endpoint} ">> /etc/profile.d/envvars.sh
                          sudo echo "export bucketregion=${var.AWS_REGION} ">> /etc/profile.d/envvars.sh
                          chmod +x /etc/profile.d/envvars.sh

                        EOF
  tags = {
    Name = "cicd"
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = "60"
  records = [aws_instance.webapp.public_ip]
}


output "rds-ip" {
  value = aws_db_instance.mysql.endpoint
}


output "ec2-ip"{
  value = aws_instance.webapp.public_ip
}
