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
  subnet_ids =[aws_subnet.main-public-2.id, aws_subnet.main-public-3.id]
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
  publicly_accessible  = true
  vpc_security_group_ids=[aws_security_group.database.id]
  db_subnet_group_name = aws_db_subnet_group.database-sn.name
  allocated_storage       = 5
  skip_final_snapshot     = true
  apply_immediately       = true
  storage_encrypted = true
  kms_key_id = aws_kms_key.rds_custom_key.arn

  tags = {
    Name = "MySql"
  }
}

output "rds-ip" {
  value = aws_db_instance.mysql.endpoint
}