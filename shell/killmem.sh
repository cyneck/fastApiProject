#!/bin/bash
# ./keep-mem-use.sh 1024 3600  &   用tmpfs文件系统占用内存 1024M

mkdir /tmp/memory
mount -t tmpfs -o size=$1M tmpfs /tmp/memory
dd if=/dev/zero of=/tmp/memory/block
sleep $2
rm /tmp/memory/block
umount /tmp/memory
rmdir /tmp/memory