#!/bin/bash
sudo kubeadm init --apiserver-cert-extra-sans <dns-name> --control-plane-endpoint <dns-name> --pod-network-cidr=172.30.0.0/16 
