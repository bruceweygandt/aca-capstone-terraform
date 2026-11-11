# Launch template stays even when the stack is off (free; keeps hardening auditable).
resource "aws_launch_template" "app" {
  name_prefix            = "${var.project}-app-"
  image_id               = data.aws_launch_template.source.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = data.aws_launch_template.source.user_data
  update_default_version = true

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted             = true
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project}-app"
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name    = "${var.project}-app-root"
      Project = var.project
    }
  }
}

resource "aws_autoscaling_group" "app" {
  count = var.stack_enabled ? 1 : 0

  name                      = "${var.project}-asg"
  min_size                  = var.asg_min
  desired_capacity          = var.asg_desired
  max_size                  = var.asg_max
  vpc_zone_identifier       = [for s in data.aws_subnet.app : s.id]
  target_group_arns         = [aws_lb_target_group.web[0].arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-app"
    propagate_at_launch = true
  }

  # Boot needs the DB (app config) and the NAT route (package/code downloads).
  depends_on = [aws_db_instance.countries, aws_route.app_default]
}

resource "aws_autoscaling_policy" "cpu_target" {
  count = var.stack_enabled ? 1 : 0

  name                   = "${var.project}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app[0].name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_percent
  }
}
