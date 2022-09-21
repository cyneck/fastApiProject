#!/bin/bash

echo "-------------------------------------------stop ntpd--------------------------------------------"
systemctl stop ntpd
systemctl disable ntpd

echo "-------------------------------------------install chrony--------------------------------------------"
yum -y install chrony

ntp_server='10.238.14.170'

ntpdate $ntp_server

ntp_server_cfg="server $ntp_server iburst"

# 替换ntp服务器地址
set -e
sed -ir "s/^server.*/$ntp_server_cfg/g" /etc/chrony.conf

echo "-------------------------------------------chrony.conf server--------------------------------------------"
cat /etc/chrony.conf |grep 'server ' -C2
systemctl restart chronyd
systemctl enable chronyd

set +e

sleep 1s

echo "----------------------------------------------ntpd status------------------------------------------------"
systemctl status ntpd

echo "---------------------------------------------chronyd status----------------------------------------------"
systemctl status chronyd
chronyc sources -v

echo "--------------------------------------------ntp timedatectl status---------------------------------------"
timedatectl status


