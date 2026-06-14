# -------------------
# RDS
# -------------------
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet-group"
  subnet_ids = [
    aws_subnet.private_db_a.id,
    aws_subnet.private_db_b.id
  ]
}

resource "aws_db_instance" "db" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "Password123!"
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  multi_az             = true
  skip_final_snapshot  = true
}