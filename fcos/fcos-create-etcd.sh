#!/bin/bash

# Prepare the disk
qemu-img create -f qcow2 -b $HOME/fcos/fedora-coreos-qemu.qcow2 $HOME/fcos/fcos-etcd.qcow2

# Create VM with persistent storage
# qemu-kvm -m 2048 -cpu host -nographic \
#	-drive if=virtio,file=$HOME/fcos/fcos-etcd.qcow2 \
#	-fw_cfg name=opt/com.coreos/config,file=etcd.ign

# Create Domain in the Virt-Manager
virt-install --connect qemu:///system -n fcos-etcd -r 2048 --os-variant=fedora31 --import \
	--graphics=none --disk path=$HOME/fcos/fcos-etcd.qcow2,backing_store=$HOME/fcos/fedora-coreos-qemu.qcow2 \
	--qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=$HOME/Kubernetes/fcos/etcd.ign" \
	--network default
