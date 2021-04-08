
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