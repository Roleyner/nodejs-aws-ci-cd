resource "aws_lb" "alb" {
  name               = "awesome-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for s in data.aws_subnet.subnets : s.id]
}

resource "aws_lb_target_group" "group" {
  name        = "awesome-lb-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  depends_on = [aws_lb.alb]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.group.arn
  }
}
