
output "alb-url" {
  value = "http://${aws_alb.my-alb.dns_name}"
}

output "alb-dns" {
  value = aws_alb.my-alb.dns_name
}

output "alb-zone-id" {
  value = aws_alb.my-alb.zone_id
}

output "alb-target-group" {
  value = aws_lb_target_group.alb-target-group
}

output "alb-sg" {
  value = aws_security_group.alb-sg
}

output "alb-listener-443" {
  value = aws_lb_listener.alb-listener-443
}