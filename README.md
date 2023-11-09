
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Azure Web App Backup Restoration Failure

This incident type occurs when a backup restoration attempt of an Azure webapp fails. Possible causes for this failure could be related to error messages or log entries, inaccessible or corrupted backup files, misconfigured database settings, or incorrect web app configuration. The failure to restore a backup can result in data loss or service disruption.

### Parameters

```shell
export WEB_APP_NAME="PLACEHOLDER"
export RESOURCE_GROUP_NAME="PLACEHOLDER"
export BACKUP_NAME="PLACEHOLDER"
export CONTAINER_URL="PLACEHOLDER"
```

## Debug

### 1. Check the status of the web app:

```shell
az webapp show --name ${WEB_APP_NAME} --resource-group ${RESOURCE_GROUP_NAME} --query state
```

### 2. Check the logs for the web app:

```shell
az webapp log tail --name ${WEB_APP_NAME} --resource-group ${RESOURCE_GROUP_NAME}
```

### 4. Check the connection strings for the web app:

```shell
az webapp config connection-string list --name ${WEB_APP_NAME} --resource-group ${RESOURCE_GROUP_NAME}
```

### Verify the application settings for a specific web app

```shell
az webapp config appsettings list --name ${WEB_APP_NAME} --resource-group ${RESOURCE_GROUP_NAME}
```

### 7. Check the backup schedule for the webapp

```shell
az webapp config backup show --name ${WEB_APP_NAME} --resource-group ${RESOURCE_GROUP_NAME} 
```

### 5. Check the backup status of the web app:

```shell
az webapp config backup list --name ${WEB_APP_NAME} --resource-group ${RESOURCE_GROUP_NAME}
```

### Backup files were corrupted or in an incorrect format.

```shell
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
```
## Repair

### Restore from the new created backup

```shell
#!/bin/bash

# Get the resource group name and webapp name
resource_group=${RESOURCE_GROUP_NAME}
webapp_name=${WEB_APP_NAME}
container_url=${CONTAINER_URL}

# Get the latest backup name
backup_name=$(az webapp config backup list --resource-group $resource_group --webapp-name $webapp_name --query "max_by([], &created).name" --output tsv)

az webapp config backup restore --backup-name $backup_name --container-url $container_url --resource-group $resource_group --webapp-name $webapp_name
```