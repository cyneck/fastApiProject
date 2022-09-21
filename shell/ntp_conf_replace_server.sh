#!/bin/bash

ntp_server='10.238.14.170'
ntp_server_cfg="server $ntp_server iburst"

# 替换ntp服务器地址
set -e
sed -ir "s/^server.*/$ntp_server_cfg/g" /etc/ntp.conf

# 查看是否修改成功
cat /etc/ntp.conf |grep 'server'

systemctl restart ntpd

# 同步时间情况
ntpq -p