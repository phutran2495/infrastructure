
resource "aws_lb" "webapp_lb" {
  name               = "webapp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.application.id]
  subnets            = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id, aws_subnet.main-public-3.id ]
}


resource "aws_lb_target_group" "webapptg" {
  name = "webapptg"
  port = 8000
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  health_check {
    path = "/books"
    port = 8000
  }
}


resource "aws_lb_listener" "webapp_lblistener" {
  load_balancer_arn = aws_lb.webapp_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapptg.arn
  }
}
