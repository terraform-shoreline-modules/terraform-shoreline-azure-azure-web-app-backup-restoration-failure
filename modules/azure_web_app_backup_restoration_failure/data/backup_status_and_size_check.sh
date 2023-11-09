#!/bin/bash

# Set variables
RESOURCE_GROUP=${RESOURCE_GROUP_NAME}
WEBAPP_NAME=${WEB_APP_NAME}
BACKUP_NAME=${BACKUP_NAME}

# Check backup status
backup_status=$(az webapp backup list --resource-group $RESOURCE_GROUP --webapp-name $WEBAPP_NAME --query "[?name=='$BACKUP_NAME'].status|[0]" -o tsv)

if [ "$backup_status" != "Succeeded" ]; then
    echo "Backup status is $backup_status, which may indicate a problem with the backup file."
fi

# Check backup size
backup_size=$(az webapp backup list --resource-group $RESOURCE_GROUP --webapp-name $WEBAPP_NAME --query "[?name=='$BACKUP_NAME'].sizeInBytes|[0]" -o tsv)

if [ "$backup_size" -lt 1000000 ]; then
    echo "Backup size is less than 1MB, which may indicate a problem with the backup file."
fi