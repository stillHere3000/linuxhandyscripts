#! /bin/bash

# This script is used to scan for viruses and rootkits.

sudo rkhunter --update --propupd
sudo rkhunter --check --skip-keypress --report-warnings-only
sudo chkrootkit
sudo clamscan -r / --bell --infected --remove --recursive --log=/var/log/clamav/clamscan.log
sudo freshclam
sudo clamscan -r / --bell --infected --remove --recursive --log=/var/log/clamav/clamscan.log
sudo chkrootkit
sudo rkhunter --check --skip-keypress --report-warnings-only
sudo rkhunter --update --propupd

#Enable the mirror checks.
#UPDATE_MIRRORS=1

#Tells rkhunter to use any mirror.
#MIRRORS_MODE=0

#Specify a command which rkhunter will use when downloading files from the Internet
#WEB_CMD=""
