resource "aws_route53_record" "route53_record" {
  zone_id=var.zone_id
  name=var.domain_name
  type="A"

  alias {
    name = aws_lb.webapp_lb.dns_name
    zone_id = aws_lb.webapp_lb.zone_id
    evaluate_target_health = true
  }
}
