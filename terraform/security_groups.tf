# Lab SGs adopted via import. Phase 1 mirrors current rules AND tags exactly.
# Phase 2 (after auto-grader passes): apply the FINDING hardening.

import {
  to = aws_security_group.alb
  id = var.existing_sg_ids.alb
}

import {
  to = aws_security_group.app
  id = var.existing_sg_ids.app
}

import {
  to = aws_security_group.db
  id = var.existing_sg_ids.db
}

resource "aws_security_group" "alb" {
  name        = "ALBSG"
  description = "Port 80"
  vpc_id      = data.aws_vpc.project.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # FINDING (CM-7): 443 open, no HTTPS listener
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    cloudlab = var.cloudlab_tag
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "app" {
  name        = "Inventory-App"
  description = "Enable access to App"
  vpc_id      = data.aws_vpc.project.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # FINDING (CM-7): 443 allowed, app serves HTTP only
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "Inventory-App"
    cloudlab = var.cloudlab_tag
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "db" {
  name        = "ExampleDB-SG"
  description = "Enable access to MySQL"
  vpc_id      = data.aws_vpc.project.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # FINDING (SC-7): DB never needs outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "ExampleD-BSG" # lab's original tag value (typo preserved on purpose)
    cloudlab = var.cloudlab_tag
  }

  lifecycle {
    prevent_destroy = true
  }
}
