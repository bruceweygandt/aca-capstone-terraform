# CIS AWS 5.4: default security groups must restrict all traffic. Adopting them with
# no rule blocks removes every rule, and puts them under code so the AWS-API and
# Terraform evidence sets cover the same groups. Nothing in this stack uses them.

resource "aws_default_security_group" "project_vpc" {
  vpc_id = data.aws_vpc.project.id

  lifecycle {
    ignore_changes = [tags, tags_all] # keep whatever tags the lab put on them
  }
}

resource "aws_default_security_group" "default_vpc" {
  vpc_id = data.aws_vpc.default.id

  lifecycle {
    ignore_changes = [tags, tags_all]
  }
}
