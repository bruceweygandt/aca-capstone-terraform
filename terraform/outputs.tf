output "app_url" {
  value = "http://${aws_lb.web.dns_name}"
}

output "db_endpoint" {
  value = aws_db_instance.countries.address
}

output "db_secret_arn" {
  value = aws_db_instance.countries.master_user_secret[0].secret_arn
}

output "asg_name" {
  value = aws_autoscaling_group.app.name
}
