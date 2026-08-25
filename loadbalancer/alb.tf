resource "aws_lb_target_group" "tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = "traffic-port"
  }

  tags = merge(local.common_tags, {
    Name = "alb-target-group"
  })
}

resource "aws_lb_target_group_attachment" "web_server" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web_server[count.index].id
  port             = 80
}

resource "aws_lb" "app_lb" {
  name                             = "my-app-lb"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.alb_sg.id]
  subnets                          = aws_subnet.public[*].id
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = merge(local.common_tags, {
    Name = "app-load-balancer"
  })
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
