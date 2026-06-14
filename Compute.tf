# -------------------
# Launch Template
# -------------------
resource "aws_launch_template" "app" {
  name_prefix   = "app-template"
  image_id      = "ami-0c76bd4bd302b30ec"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello from App Tier" > /var/www/html/index.html
EOF
  )
}

# -------------------
# Auto Scaling Group
# -------------------
resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1

  vpc_zone_identifier = [
    aws_subnet.private_app_a.id,
    aws_subnet.private_app_b.id
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]
}