
#cp big log files to local-drive
sudo cp /var/log/syslog* /var/log/ufw* /var/log/kern* -t /mnt/b9d21161-53bb-4f5a-8986-c5ff4a283e91/var_log_backupJan112024/

#remove old log files
sudo rm  /var/log/syslog* /var/log/ufw* /var/log/kern*

