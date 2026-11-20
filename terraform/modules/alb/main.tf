


# Creating security group for alb 
# Needs to allow traffic from http and https 

resource "aws_security_group" "alb-sg" {
    name = "alb-sg"
    vpc_id = var.my-vpc
}

resource "aws_vpc_security_group_ingress_rule" "alb-https-in" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Let anyone on the internet reach the load balancer on HTTP
resource "aws_vpc_security_group_ingress_rule" "alb-http-in" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb-egress" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}



# Creating the Application Load Balancer with 2 public subnets
resource "aws_alb" "my-alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  subnets         = [var.public-subnet.id, var.public-subnet-2.id]
  security_groups = [aws_security_group.alb-sg.id]
}



# Creating the target group
resource "aws_lb_target_group" "alb-target-group" {
  name        = "razzia-app-target-group"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.my-vpc
}



# Create the http and https listeners for alb
resource "aws_lb_listener" "alb-listener-80" {
  load_balancer_arn = aws_alb.my-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}



# Creating a https listener with certificate
resource "aws_lb_listener" "alb-listener-443" {
  load_balancer_arn = aws_alb.my-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06" # Just an AWS default policy. 
  certificate_arn   = var.acm-cert-arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-group.arn
  }
}
