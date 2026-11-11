# State moves for resources that gained count = var.stack_enabled ? 1 : 0.
# Without these, Terraform would destroy and recreate them.
moved {
  from = aws_db_instance.countries
  to   = aws_db_instance.countries[0]
}

moved {
  from = aws_lb.web
  to   = aws_lb.web[0]
}

moved {
  from = aws_lb_target_group.web
  to   = aws_lb_target_group.web[0]
}

moved {
  from = aws_lb_listener.http
  to   = aws_lb_listener.http[0]
}

moved {
  from = aws_autoscaling_group.app
  to   = aws_autoscaling_group.app[0]
}

moved {
  from = aws_autoscaling_policy.cpu_target
  to   = aws_autoscaling_policy.cpu_target[0]
}
