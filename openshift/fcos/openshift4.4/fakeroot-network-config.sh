mkdir -p fedora-{bootstrap,master-0,master-1,master-2,worker-0}/etc/sysconfig/network-scripts

cat > fedora-bootstrap/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.122.9
NETMASK=255.255.255.0
GATEWAY=192.168.122.1
DNS1=192.168.122.1
DNS2=8.8.8.8
DOMAIN=fcos.k8s.local
PREFIX=24
DEFROUTE=yes
IPV6INIT=no
EOF

cat > fedora-master-0/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.122.10
NETMASK=255.255.255.0
GATEWAY=192.168.122.1
DNS1=192.168.122.1
DNS2=8.8.8.8
DOMAIN=fcos.k8s.local
PREFIX=24
DEFROUTE=yes
IPV6INIT=no
EOF

cat > fedora-master-1/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.122.11
NETMASK=255.255.255.0
GATEWAY=192.168.122.1
DNS1=192.168.122.1
DNS2=8.8.8.8
DOMAIN=fcos.k8s.local
PREFIX=24
DEFROUTE=yes
IPV6INIT=no
EOF

cat > fedora-master-2/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.122.12
NETMASK=255.255.255.0
GATEWAY=192.168.122.1
DNS1=192.168.122.1
DNS2=8.8.8.8
DOMAIN=fcos.k8s.local
PREFIX=24
DEFROUTE=yes
IPV6INIT=no
EOF

cat > fedora-worker-0/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.122.13
NETMASK=255.255.255.0
GATEWAY=192.168.122.1
DNS1=192.168.122.1
DNS2=8.8.8.8
DOMAIN=fcos.k8s.local
PREFIX=24
DEFROUTE=yes
IPV6INIT=no
EOF
