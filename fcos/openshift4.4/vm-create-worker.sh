#!/bin/bash
ROLE=worker
SERVER=fedora-worker-${1}
INITRD=images/fedora-coreos-31.20200407.3.0-live-initramfs.x86_64.img
KERNEL=images/fedora-coreos-31.20191210.3.0-installer-kernel-x86_64
DISK=images/fedora-coreos-31.20191210.3.0-metal.x86_64.raw.xz

# Prepare the disk
qemu-img create -f qcow2 /var/lib/libvirt/images/$SERVER.qcow2 20G

# Create Domain in the Virt-Manager
virt-install --connect qemu:///system -n $SERVER -r 8192 --os-variant=fedora31 --import \
        --graphics=none --disk path=/var/lib/libvirt/images/$SERVER.qcow2 \
	--boot kernel=$KERNEL,initrd=$INITRD,kernel_args="ip=dhcp rd.neednet=1 coreos.inst=yes coreos.inst.install_dev=vda coreos.inst.image_url=http://192.168.122.1:8000/$DISK coreos.inst.ignition_url=http://192.168.122.1:8000/$ROLE.ign" \
        --network default
