#!/bin/bash


# This script is used to backup Wazuh data.
# It is recommended to run this script as a cron job.
# The script will create a folder with the current date and time and copy the data to it.
# The script will also create a full backup of the data.
# The script will also list the files that were backed up.

bkp_folder=/home/wzindexer_admin/OneDrive/wazuh_indexer/agent_data/$(date +%F_%H) # Change this path to your backup folder
mkdir -p $bkp_folder && echo $bkp_folder # Create the backup folder if it doesn't exist

echo "Backing up agent data..." # Backup agent data

sudo rsync -arREz \
/var/ossec/etc/client.keys \
/var/ossec/etc/ossec.conf \
/var/ossec/etc/internal_options.conf \
/var/ossec/etc/local_internal_options.conf \
/var/ossec/etc/*.pem \
/var/ossec/logs/ \
/var/ossec/queue/rids/ $bkp_folder



full_folder=/home/wzindexer_admin/OneDrive/wazuh_indexer/full_backup_data/$(date +%F_%H) # Change this path to your backup folder
sudo mkdir -p $full_folder &&  sudo echo $full_folder # Create the backup folder if it doesn't exist

echo "Backing up full data..." # Backup full data

sudo rsync -arREz -va --progress \
/var/ossec/integrations \
/var/ossec/.ssh \
/var/ossec/tmp \
/var/ossec/lib \
/var/ossec/api \
/var/ossec/framework \
/var/ossec/agentless \
/var/ossec/var \
/var/ossec/etc \
/var/ossec/queue \
/var/ossec/bin \
/var/ossec/stats \
/var/ossec/active-response \
/var/ossec/ruleset \
/var/ossec/backup \
/var/ossec/wodles $full_folder

echo "Done!" # List the files that were backed up

echo "Listing files..."

sudo find $bkp_folder -type f | sudo sed "s|$bkp_folder/||" | less
sudo find $full_folder -type f | sudo sed "s|$full_folder/||" | less

echo "Done!"
