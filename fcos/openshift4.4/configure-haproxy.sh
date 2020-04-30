#!/bin/bash

sudo yum install haproxy -y
pushd haproxy-configuration

sudo cp haproxy.cfg /etc/haproxy/haproxy.cfg

popd

systemctl enable --now haproxy
