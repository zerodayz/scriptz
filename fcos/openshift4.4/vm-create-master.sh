#!/bin/bash
ROLE=master
SERVER=fedora-master-${1}
INITRD=images/fedora-coreos-31.20200407.3.0-live-initramfs.x86_64.img
KERNEL=images/fedora-coreos-31.20191210.3.0-installer-kernel-x86_64
DISK=images/fedora-coreos-31.20191210.3.0-metal.x86_64.raw.xz

IPADDR=192.168.122.1${1}
DEFAULTGW=192.168.122.1
NETMASK=255.255.255.0
INTERFACE=eth0
DNS=192.168.122.1

# Prepare the disk
qemu-img create -f qcow2 /var/lib/libvirt/images/$SERVER.qcow 40G

# Create Domain in the Virt-Manager
virt-install --connect qemu:///system -n $SERVER -r 16384 --os-variant=fedora31 --import \
        --graphics=none --disk path=/var/lib/libvirt/images/$SERVER.qcow \
	--boot kernel=$KERNEL,initrd=$INITRD,kernel_args="ip=$IPADDR::$DEFAULTGW:$NETMASK:$SERVER:$INTERFACE:none:$DNS rd.neednet=1 coreos.inst=yes coreos.inst.install_dev=vda coreos.inst.image_url=http://192.168.122.1:8000/$DISK coreos.inst.ignition_url=http://192.168.122.1:8000/ignition/$ROLE-${1}.ign" \
        --network default
