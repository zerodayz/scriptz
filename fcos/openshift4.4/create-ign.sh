#!/bin/bash

if [ -d deploy ]; then
    echo "Directory deploy already exists."
    exit 1
fi
mkdir deploy
openshift-install create ignition-configs --dir=deploy/
