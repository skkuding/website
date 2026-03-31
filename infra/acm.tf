resource "aws_acm_certificate" "skkuding" {
  provider                  = aws.us_east_1
  domain_name               = "skkuding.dev"
  subject_alternative_names = ["*.skkuding.dev"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "skkuding_certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.skkuding.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.skkuding.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 300
  records         = [each.value.value]
}

resource "aws_acm_certificate_validation" "skkuding" {
  provider = aws.us_east_1

  certificate_arn = aws_acm_certificate.skkuding.arn
  validation_record_fqdns = [
    for record in aws_route53_record.skkuding_certificate_validation : record.fqdn
  ]
}
