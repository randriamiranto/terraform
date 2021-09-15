output "elb_public_dns" {
  description = "The public DNS name assigned to the instance."
  value       = aws_elb.elb-wp.dns_name
}

