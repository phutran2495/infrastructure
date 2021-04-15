
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
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:us-east-1:709891834787:certificate/88d7d2a6-c86b-4efa-bc2d-5be37a1ffe77"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapptg.arn
  }
}
