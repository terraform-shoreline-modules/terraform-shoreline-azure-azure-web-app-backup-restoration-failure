resource "shoreline_notebook" "azure_web_app_backup_restoration_failure" {
  name       = "azure_web_app_backup_restoration_failure"
  data       = file("${path.module}/data/azure_web_app_backup_restoration_failure.json")
  depends_on = [shoreline_action.invoke_check_backup_status_size,shoreline_action.invoke_restore_backup]
}

resource "shoreline_file" "check_backup_status_size" {
  name             = "check_backup_status_size"
  input_file       = "${path.module}/data/check_backup_status_size.sh"
  md5              = filemd5("${path.module}/data/check_backup_status_size.sh")
  description      = "Backup files were corrupted or in an incorrect format."
  destination_path = "/tmp/check_backup_status_size.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "restore_backup" {
  name             = "restore_backup"
  input_file       = "${path.module}/data/restore_backup.sh"
  md5              = filemd5("${path.module}/data/restore_backup.sh")
  description      = "Restore from the new created backup"
  destination_path = "/tmp/restore_backup.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_backup_status_size" {
  name        = "invoke_check_backup_status_size"
  description = "Backup files were corrupted or in an incorrect format."
  command     = "`chmod +x /tmp/check_backup_status_size.sh && /tmp/check_backup_status_size.sh`"
  params      = ["BACKUP_NAME","WEB_APP_NAME","RESOURCE_GROUP_NAME"]
  file_deps   = ["check_backup_status_size"]
  enabled     = true
  depends_on  = [shoreline_file.check_backup_status_size]
}

resource "shoreline_action" "invoke_restore_backup" {
  name        = "invoke_restore_backup"
  description = "Restore from the new created backup"
  command     = "`chmod +x /tmp/restore_backup.sh && /tmp/restore_backup.sh`"
  params      = ["CONTAINER_URL","WEB_APP_NAME","RESOURCE_GROUP_NAME"]
  file_deps   = ["restore_backup"]
  enabled     = true
  depends_on  = [shoreline_file.restore_backup]
}

