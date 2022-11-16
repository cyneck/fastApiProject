#!/bin/bash

echo "init env..."

function check_os_boot_mode() {
  mode=$([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS)
  if [[ $mode == "BIOS" ]]; then
    echo "check_os_boot_mode is BIOS (succeed)"
    Green_Success check_os_boot_mode
  else
    echo "check_os_boot_mode BIOS is fail" >error.log
    Red_Error
  fi
}

function check_linux_version() {
  os=$(cat /etc/redhat-release | awk '{print $1}')
  version=$(cat /etc/redhat-release | awk '{print $4}')
  tlinux_os=$(cat /etc/issue)
  result=$(echo $tlinux_os | grep "Tencent Linux release 2.4")
  if [[ $result != '' ]]; then
    echo "check os is $os (right)"
  else
    result=$(echo $version | grep "7.6")
    result2=$(echo $version | grep "7.9")
    if [[ $os == "CentOS" && $result != "" ]]; then
      echo "check os is $os $version (right)"
      Green_Success check_linux_version
    elif [[ $os == "CentOS" && $result2 != "" ]]; then
      echo "check os is $os $version (right)"
      Green_Success check_linux_version
    else
      echo "check os is $os $version (not match)" >>error.log
      Yellow_Warnning
    fi
  fi
}

function check_linux_kernel() {
  kernel=$(uname -r | tr -cd "[0-9]" | cut -c 1-3)
  minVersion=310
  if [[ $kernel -ge $minVersion ]]; then
    echo "check_linux_kernel is $kernel (succeed)"
    Green_Success check_linux_kernel
  else
    echo "check_linux_kernel is $kernel (not match)" >>error.log
    Yellow_Warnning check_linux_kernel
  fi
}

function install_base_package() {
  yum install -y jq sshpass socat bind-utils net-tools ntpdate redhat-lsb lvm2
  if [[ $? -eq 0 ]]; then
    echo "install_base_package (succeed)"
    Green_Success install_base_package
  else
    echo "install_base_package (fail)" >>error.log
    Red_Error install_base_package
  fi
}

function add_network_bridge_filter() {
  modprobe br_netfilter
  echo 1 >/proc/sys/net/bridge/bridge-nf-call-iptables
  echo 1 >/proc/sys/net/bridge/bridge-nf-call-ip6tables
  if [[ $? -eq 0 ]]; then
    echo "add_network_bridge_filter (succeed)"
    Green_Success add_network_bridge_filter
  else
    echo "add_network_bridge_filter (fail)" >>error.log
    Red_Error add_network_bridge_filter
  fi
}

function add_sysctl_conf() {
  echo "vm.swappiness=0" >>/etc/sysctl.conf
  swapoff -a
  sed -i -r '/swap/s/^/#/' /etc/fstab

  echo 'vm.max_map_count=262144
net.ipv4.ip_forward=1
vm.drop_caches=3
kernel.pid_max=1000000
fs.inotify.max_user_instances=524288' >>/etc/sysctl.conf

  sysctl -p

  if [[ $? -eq 0 ]]; then
    echo "add_sysctl_conf (succeed)"
    Green_Success add_sysctl_conf
  else
    echo "add_sysctl_conf (fail)" >>error.log
    Red_Error add_sysctl_conf
  fi
}

function stop_firewalld() {
  systemctl stop firewalld
  systemctl disable firewalld
  if [[ $? -eq 0 ]]; then
    echo "stop_firewalld (succeed)"
    Green_Success stop_firewalld
  else
    echo "stop_firewalld (fail)" >>error.log
    Red_Error stop_firewalld
  fi
}

function close_selinux() {
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  if [[ $? -eq 0 ]]; then
    echo "close_selinux (succeed)"
    Green_Success close_selinux
  else
    echo "close_selinux (fail)" >>error.log
    Red_Error close_selinux
  fi
}

function set_time_zone() {
  timedatectl set-timezone Asia/Shanghai
  if [[ $? -eq 0 ]]; then
    echo "set_time_zone (succeed)"
    Green_Success set_time_zone
  else
    echo "set_time_zone (fail)" >>error.log
    Red_Error set_time_zone
  fi
}

function set_hostname_ip() {
  ip=$(ifconfig | grep -A1 "eth0" | grep 'inet' | awk -F ' ' '{print $2}')
  hostname=$(hostname)
  if [[ $ip != "" && $hostname != "" ]]; then
    echo $ip $hostname >>/etc/hosts
    if [[ $? -eq 0 ]]; then
      echo "set_hostname_ip (succeed)"
      Green_Success
    else
      echo "set_hostname_ip (fail)" >>error.log
      Red_Error set_hostname_ip
    fi
  else
    echo "set_hostname_ip ip or hostname is null. (fail)" >>error.log
    Red_Error set_hostname_ip
  fi

}

function set_data_dir_chmod() {
  chmod 777 /tmp
  chmod 755 /data
  if [[ $? -eq 0 ]]; then
    echo "set_data_dir_chmod (succeed)"
    Green_Success set_data_dir_chmod
  else
    echo "set_data_dir_chmod (fail)" >>error.log
    Red_Error set_data_dir_chmod
  fi
}

function set_iptable_nat() {
  modprobe iptable_nat && echo iptable_nat >>/etc/modules-load.d/cpaas.conf
  if [[ $? -eq 0 ]]; then
    echo "set_iptable_nat (succeed)"
    Green_Success set_iptable_nat
  else
    echo "set_iptable_nat (fail)" >>error.log
    Red_Error set_iptable_nat
  fi
}

function set_core_file() {
  ulimit -c 0 && echo 'ulimit -S -c 0' >>/etc/profile
  if [[ $? -eq 0 ]]; then
    echo "set_core_file (succeed)"
    Green_Success set_core_file
  else
    echo "set_core_file (fail)" >>error.log
    Red_Error set_core_file
  fi
}

Green_Success() {
  echo '================================================='

  printf '\033[1;32;40m[success]  %b\033[0m\n' "$1"

}

Yellow_Warnning() {
  echo '================================================='

  printf '\033[1;33;40m[warnning]  %b\033[0m\n' "$1"

}

Red_Error() {
  echo '================================================='

  printf '\033[1;31;40m[error]  %b\033[0m\n' "$1"

  exit 1

}

check_os_boot_mode
check_linux_version
check_linux_kernel
install_base_package
add_network_bridge_filter
add_sysctl_conf
stop_firewalld
close_selinux
set_time_zone
set_hostname_ip
set_data_dir_chmod
set_iptable_nat
set_core_file

grub2-mkconfig -o /boot/grub2/grub.cfg

echo "end! please reboot!"

