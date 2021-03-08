#!/bin/bash

yum -y install nfs-utils
# prepare disk
# fdisk /dev/sdb
# mkfs.ext4 /dev/sdb1
mkdir /mnt/disks
mount /dev/sdb1 /mnt/disks
cd /mnt/disks
for i in `seq 1 10`; do mkdir vol$i; done
echo "/mnt/disks *(insecure,rw)" >> /etc/exports
exportfs -arv
