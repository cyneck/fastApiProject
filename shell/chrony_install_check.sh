#!/bin/bash


function WARN() {
YELOW_COLOR='\E[1;33m'#黄
RES='\E[0m'
echo -e  "${YELOW_COLOR} [WARN] ${1} ${RES}"
}

function SUCCESS() {
GREEN_COLOR='\E[1;32m'#绿
RES='\E[0m'
echo -e  "${GREEN_COLOR} [SUCCESS] ${1} ${RES}"
}

function INFO() {
BLUE_COLOR='\E[1;34m' #蓝
RES='\E[0m'
echo -e  "${BLUE_COLOR} [INFO]==========${1}==========${RES}"
}

function ERROR() {
RED_COLOR='\E[1;31m'  #红
RES='\E[0m'
echo -e  "${RED_COLOR} [ERROR] ${1} ${RES}"
}


# -n ntp服务器
# 输入增加-n 参数，并判空
ntp_server=''
while getopts ":n:" opt; do
  case $opt in
  n)
    # echo "n参数的值${OPTARG}"
    ntp_server=${OPTARG}
    ;;
  ?)
    ERROR "未知参数值${OPTARG}"
    exit 1
    ;;
  esac
done

if [ "$ntp_server" =  "" ];then
  ERROR "ntp服务器地址不能为空,请重新输入,加入合适的参数值，例如：-n 127.127.1.0"
  exit 1
fi

#echo $ntp_server

INFO "----------stop ntpd ------------"
systemctl stop ntpd
systemctl disable ntpd

INFO "----------install chrony--------"
yum -y install chrony

#ntp_server='10.238.14.170'

ntpdate $ntp_server

ntp_server_cfg="server $ntp_server iburst"

# 替换ntp服务器地址
set -e
sed -ir "s/^server.*/$ntp_server_cfg/g" /etc/chrony.conf

INFO "-------chrony.conf server--------"
cat /etc/chrony.conf | grep 'server ' -C2
systemctl restart chronyd
systemctl enable chronyd

set +e

sleep 1s

INFO "----------ntpd status------------"
systemctl status ntpd

INFO "--------chronyd status-----------"
systemctl status chronyd
chronyc sources -v

INFO "-----ntp timedatectl status-------"
timedatectl status

SUCCESS "安装配置成功！"

