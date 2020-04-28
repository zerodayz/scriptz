#!/bin/bash

# Destroy the domain and deletes the disk
sudo virsh destroy fcos-etcd
sudo virsh undefine fcos-etcd
rm -Rf $HOME/fcos/fcos-etcd.qcow2
