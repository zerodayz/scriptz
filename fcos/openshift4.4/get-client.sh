#!/bin/bash
curl 'https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz' -o oc.tar.gz
sudo tar -xf oc.tar.gz -C /usr/local/bin
oc adm release extract --tools quay.io/openshift/okd:4.4.0-0.okd-2020-04-21-163702-beta4
sudo tar -xf openshift-client-linux-4.4.0-0.okd-2020-04-21-163702-beta4.tar.gz -C /usr/local/bin
sudo tar -xf openshift-install-linux-4.4.0-0.okd-2020-04-21-163702-beta4.tar.gz -C /usr/local/bin
