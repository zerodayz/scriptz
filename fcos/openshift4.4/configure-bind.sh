#!/bin/bash
sudo yum -y install bind

pushd named-configuration
sudo cp named.conf /etc/named.conf
sudo cp named.conf.local /etc/named/named.conf.local
sudo mkdir /var/named/zones/
sudo cp db.192.168.122 /var/named/zones/db.192.168.122
sudo cp db.fcos.k8s.local /var/named/zones/db.fcos.k8s.local

sudo systemctl enable --now named

popd
