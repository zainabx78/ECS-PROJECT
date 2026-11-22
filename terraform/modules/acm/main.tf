

# Creating a certificate to use with the https listener on the alb. 
resource "aws_acm_certificate" "https-ssl-cert" {
  domain_name       = "aws.zainabf.co.uk"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

}


# For the CNAME record needed in route53 - for validation for the certificate:

# Look up the existing hosted zone
data "aws_route53_zone" "razzia" {
  name         = "aws.zainabf.co.uk"
  private_zone = false
}

# Create the CNAME record AWS needs to check you own the domain
resource "aws_route53_record" "cert-validation" {
  for_each = {
    for dvo in aws_acm_certificate.https-ssl-cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.razzia.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

# Wait until AWS confirms the certificate is approved
resource "aws_acm_certificate_validation" "cert-validation" {
  certificate_arn         = aws_acm_certificate.https-ssl-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-validation : record.fqdn]
}


# NEED TO TEST THIS