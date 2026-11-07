data "aws_vpc" "project" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet" "public" {
  for_each = toset(var.public_subnet_names)
  vpc_id   = data.aws_vpc.project.id
  tags = {
    Name = each.value
  }
}

data "aws_subnet" "app" {
  for_each = toset(var.app_subnet_names)
  vpc_id   = data.aws_vpc.project.id
  tags = {
    Name = each.value
  }
}

data "aws_launch_template" "source" {
  name = var.source_launch_template_name
}
