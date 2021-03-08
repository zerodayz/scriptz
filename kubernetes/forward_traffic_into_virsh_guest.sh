#!/bin/bash

iptables -I FORWARD -o tt0 -d  192.168.126.11 -j ACCEPT
iptables -t nat -I PREROUTING -p tcp --dport 6443 -j DNAT --to 192.168.126.11:6443

iptables -I FORWARD -o tt0 -d  192.168.126.11 -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.126.0/24 -j MASQUERADE
iptables -A FORWARD -o tt0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i tt0 -o em1 -j ACCEPT
iptables -A FORWARD -i tt0 -o lo -j ACCEPT
