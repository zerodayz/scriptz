#!/bin/bash

sudo yum install haproxy -y
pushd haproxy-configuration

sudo cp haproxy.cfg /etc/haproxy/haproxy.cfg

popd

sudo setsebool -P haproxy_connect_any on
systemctl enable --now haproxy
