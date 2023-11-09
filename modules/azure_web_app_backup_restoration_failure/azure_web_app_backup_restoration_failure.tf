resource "shoreline_notebook" "azure_web_app_backup_restoration_failure" {
  name       = "azure_web_app_backup_restoration_failure"
  data       = file("${path.module}/data/azure_web_app_backup_restoration_failure.json")
  depends_on = [shoreline_action.invoke_backup_status_and_size_check,shoreline_action.invoke_restore_webapp_backup]
}

resource "shoreline_file" "backup_status_and_size_check" {
  name             = "backup_status_and_size_check"
  input_file       = "${path.module}/data/backup_status_and_size_check.sh"
  md5              = filemd5("${path.module}/data/backup_status_and_size_check.sh")
  description      = "Backup files were corrupted or in an incorrect format."
  destination_path = "/tmp/backup_status_and_size_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "restore_webapp_backup" {
  name             = "restore_webapp_backup"
  input_file       = "${path.module}/data/restore_webapp_backup.sh"
  md5              = filemd5("${path.module}/data/restore_webapp_backup.sh")
  description      = "Restore from the new created backup"
  destination_path = "/tmp/restore_webapp_backup.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_backup_status_and_size_check" {
  name        = "invoke_backup_status_and_size_check"
  description = "Backup files were corrupted or in an incorrect format."
  command     = "`chmod +x /tmp/backup_status_and_size_check.sh && /tmp/backup_status_and_size_check.sh`"
  params      = ["RESOURCE_GROUP_NAME","BACKUP_NAME","WEB_APP_NAME"]
  file_deps   = ["backup_status_and_size_check"]
  enabled     = true
  depends_on  = [shoreline_file.backup_status_and_size_check]
}

resource "shoreline_action" "invoke_restore_webapp_backup" {
  name        = "invoke_restore_webapp_backup"
  description = "Restore from the new created backup"
  command     = "`chmod +x /tmp/restore_webapp_backup.sh && /tmp/restore_webapp_backup.sh`"
  params      = ["CONTAINER_URL","RESOURCE_GROUP_NAME","WEB_APP_NAME"]
  file_deps   = ["restore_webapp_backup"]
  enabled     = true
  depends_on  = [shoreline_file.restore_webapp_backup]
}

