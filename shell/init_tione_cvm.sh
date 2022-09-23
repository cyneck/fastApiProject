#!/bin/bash

#-------------------------------------------------------消息提示
function WARN() {
  YELOW_COLOR='\E[1;33m' #黄
  RES='\E[0m'
  echo -e "${YELOW_COLOR} [WARN] ${1} ${RES}"
}

function SUCCESS() {
  GREEN_COLOR='\E[1;32m' #绿
  RES='\E[0m'
  echo -e "${GREEN_COLOR} [SUCCESS] ${1} ${RES}"
}

function INFO() {
  BLUE_COLOR='\E[1;34m' #蓝
  RES='\E[0m'
  echo -e "${BLUE_COLOR} [INFO]==========${1}==========${RES}"
}

function ERROR() {
  RED_COLOR='\E[1;31m' #红
  RES='\E[0m'
  echo -e "${RED_COLOR} [ERROR] ${1} ${RES}"
  exit 1
}

#--------------------------------------------------------功能模块

function boot_mode_check() {
  set -e
  boot_mode=$([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS)
  set +e
  if [ "$boot_mode" = 'BIOS' ]; then
    SUCCESS '启动模式为Legacy'
  else
    ERROR '启动模式不为Legacy'
  fi
}

function install_pkg() {
  set -e
  yum install -y jq sshpass socat bind-utils net-tools ntpdate redhat-lsb
  set +e
  SUCCESS '安装基础依赖包jq sshpass socat bind-utils net-tools ntpdate redhat-lsb'
}

function br_netfilter() {
  set -e
  modprobe br_netfilter
  echo 1 >/proc/sys/net/bridge/bridge-nf-call-iptables
  echo 1 >/proc/sys/net/bridge/bridge-nf-call-ip6tables
  set +e
  SUCCESS '添加网桥过滤'
}

function swap_off() {
  set -e
  echo "vm.swappiness = 0" >>/etc/sysctl.conf
  sysctl -p
  swapoff -a
  sed -ir '/swap/s/^/#/' /etc/fstab
  set +e

  free -h
  SUCCESS 'swap_off'
}

function stop_firewalld() {
  set -e
  systemctl stop firewalld
  systemctl disable firewalld
  set +e
  SUCCESS '关闭防火墙'
}

function stop_selinux() {
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  SUCCESS '关闭selinux'
}

function set_timezone() {
  timedatectl set-timezone Asia/Shanghai
  if [ $? -eq 0 ]; then
    SUCCESS '服务器时区Asia/Shanghai成功'
  else
    ERROR "服务器时区Asia/Shanghai失败"
  fi

}

function set_sysctl_conf() {

  item_array=("vm.max_map_count" "net.ipv4.ip_forward" "vm.drop_caches"
    "kernel.pid_max" "fs.inotify.max_user_instances" "net.ipv6.conf.all.disable_ipv6"
    "net.ipv6.conf.default.disable_ipv6" "net.ipv6.conf.lo.disable_ipv6")

  item_value_array=("vm.max_map_count=262144" "net.ipv4.ip_forward=1" "vm.drop_caches=3"
    "kernel.pid_max=1000000" "fs.inotify.max_user_instances=524288" "net.ipv6.conf.all.disable_ipv6=0"
    "net.ipv6.conf.default.disable_ipv6=0" "net.ipv6.conf.lo.disable_ipv6=0")

  # ${#<数组名>[@]} 获取数组长度
  # ${<数组名>[i]}  获取第i个位置的元素，下标是 0-base
  # seq x y        产生一个从 x 到 y 的整数序列，包括两端点
  # expr           计算表达式

  for i in $(seq 0 $(expr ${#item_array[@]} - 1)); do
    item=${item_array[i]}
    item_value=${item_value_array[i]}
    value=$(cat /etc/sysctl.conf | grep "$item")
    if [ -z "$value" ]; then
      echo "$item_value" >>/etc/sysctl.conf
    else
      sed -ir "s/^$item.*/$item_value/g" /etc/sysctl.conf
    fi
  done

  set -e
  cat /etc/sysctl.conf | grep -E "vm|net|fs|kernel"
  sysctl -p
  if [ $? -eq 0 ]; then
    SUCCESS "设置sysctl_conf成功"
  else
    ERROR "设置sysctl_conf失败"
  fi
  set +e

}

function set_hosts() {
  ip=$(ifconfig | grep "eth0" -A7 | grep -E "inet\s+" | sed -E -e "s/inet\s+\S+://g" | awk '{print $2}')
  new_hosts="$ip $(hostname)"
  value=$(cat /etc/hosts | grep "$new_hosts")
  if [ -z "$value" ]; then
    echo $new_hosts >>/etc/hosts
  fi
  cat /etc/hosts
  SUCCESS "set /etc/hosts成功"
}

function set_dir_chmod() {
  chmod 777 /tmp
  chmod 755 /data
}

function set_iptable_nat() {
  set -e
  modprobe iptable_nat && echo iptable_nat >>/etc/modules-load.d/cpaas.conf
  set +e
}

function set_core_profile() {
  ulimit -c 0 && echo 'ulimit -S -c 0' >>/etc/profile
}

function check_avx2() {
  value=$(cat /proc/cpuinfo | grep avx2)
  if [ -z "$value" ]; then
    cat /proc/cpuinfo | grep avx2
    SUCCESS 'avx2指令集支持'
  fi
}

function set_grub_config() {
  value=$(cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX")
  if [ -z "$value" ]; then
    has=$(cat /etc/default/grub | grep "ipv6.disable=1")
    if [ -z "$has" ]; then
      sed -ir "s/ipv6.disable=1//" /etc/default/grub
    fi

    # 增加cgroup.memory=nokmem
    grub_cmd=$(cat /etc/default/grub | grep GRUB_CMDLINE_LINUX | awk '{print $1}')
    grub_cmd_new="$grub_cmd cgroup.memory=nokmem"
    sed -i "s/$grub_cmd/$grub_cmd_new/" /etc/default/grub
    cat /etc/default/grub | grep GRUB_CMDLINE_LINUX
  fi

  grub2-mkconfig -o /boot/grub2/grub.cfg
  if [ $? -eq 0 ]; then
    SUCCESS "设置grub成功"
  else
    ERROR "设置grub失败"
  fi

}

function make_dir() {
  mkdir -p /data/ti-platform/ && chmod 755 /data/ti-platform/
  mkdir /data/ti-platform-fs
  INFO "新建ti-platform目录和ti-platform-fs目录（如果已经存在将会忽略）"
}

INFO "开始..."
boot_mode_check

install_pkg

br_netfilter

swap_off

stop_firewalld

stop_selinux

set_timezone

set_sysctl_conf

set_hosts

set_dir_chmod

set_iptable_nat

set_core_profile

check_avx2

set_grub_config

make_dir

INFO "正常结束！"
