#!/bin/bash

# Get the resource group name and webapp name
resource_group=${RESOURCE_GROUP_NAME}
webapp_name=${WEB_APP_NAME}
container_url=${CONTAINER_URL}

# Get the latest backup name
backup_name=$(az webapp config backup list --resource-group $resource_group --webapp-name $webapp_name --query "max_by([], &created).name" --output tsv)

az webapp config backup restore --backup-name $backup_name --container-url $container_url --resource-group $resource_group --webapp-name $webapp_name