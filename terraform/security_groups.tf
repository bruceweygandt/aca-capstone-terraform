# Lab SGs adopted via import (rules + lab tags mirrored).
# Phase 2: least-privilege egress per tier (KSI-CNA-RNT / SC-7). Egress targets use
# subnet CIDRs rather than SG references, which would create an ALB -> app -> DB cycle.

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

locals {
  app_subnet_cidrs = [for s in data.aws_subnet.app : s.cidr_block]
  db_subnet_cidrs  = [for s in data.aws_subnet.db : s.cidr_block]
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
    description = "Forward requests and health checks to the app tier only"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.app_subnet_cidrs
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
    description = "HTTPS via NAT: packages, app download, Secrets Manager, RDS API, SSM"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "MySQL to the DB subnets only"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = local.db_subnet_cidrs
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

  # The database never initiates connections: no egress at all.
  egress = []

  tags = {
    Name     = "ExampleD-BSG" # lab's original tag value (typo preserved on purpose)
    cloudlab = var.cloudlab_tag
  }

  lifecycle {
    prevent_destroy = true
  }
}
