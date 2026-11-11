output "stack_enabled" {
  value = var.stack_enabled
}

output "app_url" {
  value = try("http://${aws_lb.web[0].dns_name}", null)
}

output "db_endpoint" {
  value = try(aws_db_instance.countries[0].address, null)
}

output "db_secret_arn" {
  value = try(aws_db_instance.countries[0].master_user_secret[0].secret_arn, null)
}

output "asg_name" {
  value = try(aws_autoscaling_group.app[0].name, null)
}
