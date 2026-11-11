# Lab NAT gateway, adopted into Terraform so it can be switched off when idle.
# NAT (~$1.20/day with its public IP) is the largest idle cost in this environment.

data "aws_route_table" "app" {
  vpc_id = data.aws_vpc.project.id
  tags = {
    Name = var.app_route_table_name
  }
}

resource "aws_eip" "nat" {
  count  = var.stack_enabled ? 1 : 0
  domain = "vpc"
  tags = {
    cloudlab = var.cloudlab_tag
  }
}

resource "aws_nat_gateway" "lab" {
  count         = var.stack_enabled ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = data.aws_subnet.public[var.nat_subnet_name].id
  tags = {
    Name     = "Lab-NATGW"
    cloudlab = var.cloudlab_tag
  }
}

resource "aws_route" "app_default" {
  count                  = var.stack_enabled ? 1 : 0
  route_table_id         = data.aws_route_table.app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.lab[0].id
}
