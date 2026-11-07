# RDS-managed secret ("rds!" prefix, username/password keys) matches get-parameters.php.
# App uses the FIRST RDS instance and FIRST secret: keep exactly one of each.

resource "aws_db_instance" "countries" {
  identifier     = "${var.project}-mysql"
  engine         = "mysql"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name                     = "countries"
  username                    = "admin"
  manage_master_user_password = true

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = var.db_multi_az

  backup_retention_period    = var.db_backup_retention_days
  copy_tags_to_snapshot      = true
  auto_minor_version_upgrade = true
  apply_immediately          = true

  deletion_protection = false
  skip_final_snapshot = true
}
