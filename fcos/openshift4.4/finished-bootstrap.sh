#!/bin/bash

pushd haproxy-configuration

sudo cp bootstrap-finished-haproxy.cfg /etc/haproxy/haproxy.cfg

popd

systemctl restart haproxy
