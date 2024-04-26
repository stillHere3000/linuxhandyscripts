#! /bin/bash

# Disable tmp noexec permissions
sudo mount -o remount,exec /tmp

sudo ./thor-cloud-launcher 

#enable tmp noexec permissions
sudo mount -o remount,noexec /tmp