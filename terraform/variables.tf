variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "aca-capstone"
}

variable "environment" {
  type    = string
  default = "lab"
}

variable "vpc_name" {
  type    = string
  default = "Project VPC"
}

variable "public_subnet_names" {
  type    = list(string)
  default = ["Public Subnet 1", "Public Subnet 2"]
}

variable "app_subnet_names" {
  type    = list(string)
  default = ["Private Subnet 1", "Private Subnet 2"]
}

variable "db_subnet_group_name" {
  type = string
}

variable "existing_sg_ids" {
  type = object({
    alb = string
    app = string
    db  = string
  })
}

variable "source_launch_template_name" {
  type    = string
  default = "Project-LT"
}

variable "instance_profile_name" {
  type    = string
  default = "Inventory-App-Role"
}

variable "key_name" {
  type    = string
  default = "vockey"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "asg_min" {
  type    = number
  default = 2
}

variable "asg_desired" {
  type    = number
  default = 2
}

variable "asg_max" {
  type    = number
  default = 4
}

variable "cpu_target_percent" {
  type    = number
  default = 50
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_engine_version" {
  type    = string
  default = "8.0"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_backup_retention_days" {
  type    = number
  default = 1
}

variable "cloudlab_tag" {
  description = "Lab-assigned tracking tag on pre-provisioned resources; preserve on import"
  type        = string
}

# ---------- Cost switch ----------
variable "stack_enabled" {
  description = "false = remove all billable resources (NAT, EIP, ALB, ASG, RDS); SGs and launch template stay"
  type        = bool
  default     = true
}

variable "nat_subnet_name" {
  type    = string
  default = "Public Subnet 1"
}

variable "app_route_table_name" {
  type    = string
  default = "Private Route Table App"
}
