#!/bin/bash

if [ -d ignition ]; then
    echo "Directory ignition already exists."
    exit 1
fi
mkdir ignition
filetranspiler -i deploy/bootstrap.ign -f fedora-bootstrap -o ignition/bootstrap.ign
filetranspiler -i deploy/master.ign -f fedora-master-0 -o ignition/master-0.ign
filetranspiler -i deploy/master.ign -f fedora-master-1 -o ignition/master-1.ign
filetranspiler -i deploy/master.ign -f fedora-master-2 -o ignition/master-2.ign
filetranspiler -i deploy/worker.ign -f fedora-worker-0 -o ignition/worker-0.ign

