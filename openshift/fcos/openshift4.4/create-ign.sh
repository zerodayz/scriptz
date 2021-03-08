#!/bin/bash

if [ -d deploy ]; then
    echo "Directory deploy already exists."
    exit 1
fi
mkdir deploy
cp install-config.yaml deploy/

pushd deploy
openshift-install create ignition-configs 
popd
