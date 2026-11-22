

# Using a pre-created DNS zone 
# It also has 4 namesevers set up already 
# Stays out of terraform so won't need to keep creating NS records everytime tf destroy and apply again. 
data "aws_route53_zone" "razzia" {
  name         = "aws.zainabf.co.uk"
  private_zone = false
}





# Creating an Alias record for traffic to be routed to load balancer when using custom domain
resource "aws_route53_record" "a-record-alb" {
  type            = "A"
  name            = "aws.zainabf.co.uk"
  zone_id         = data.aws_route53_zone.razzia.zone_id
  allow_overwrite = true

  alias {
    name                   = var.alb-dns
    zone_id                = var.alb-zone-id
    evaluate_target_health = true
  }

}







