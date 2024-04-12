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
