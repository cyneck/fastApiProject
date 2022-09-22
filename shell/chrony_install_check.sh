#!/bin/bash

# -n ntp服务器
# 输入增加-n 参数，并判空
ntp_server=''
while getopts ":n:" opt; do
  case $opt in
  n)
    # echo "n参数的值${OPTARG}"
    ntp_server=${OPTARG}
    ;;
  \?)
    echo "未知参数${OPTARG}"
    exit 1
    ;;
  esac
done

if [ "$ntp_server" =  "" ];then
  echo "ntp服务器地址不能为空,请重新输入,加入合适的参数值，例如：-n 127.127.1.0"
  exit 1
fi

#echo $ntp_server

echo "-------------------------------------------stop ntpd--------------------------------------------"
systemctl stop ntpd
systemctl disable ntpd

echo "-------------------------------------------install chrony--------------------------------------------"
yum -y install chrony

#ntp_server='10.238.14.170'

ntpdate $ntp_server

ntp_server_cfg="server $ntp_server iburst"

# 替换ntp服务器地址
set -e
sed -ir "s/^server.*/$ntp_server_cfg/g" /etc/chrony.conf

echo "-------------------------------------------chrony.conf server--------------------------------------------"
cat /etc/chrony.conf | grep 'server ' -C2
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
