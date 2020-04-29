#!/bin/bash
curl 'https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz' -o oc.tar.gz
sudo tar -xf oc.tar.gz -C /usr/local/bin
