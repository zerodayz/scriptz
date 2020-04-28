#!/bin/bash

if [ $# -ne 1 ]; then
    echo "please specify fcc file."
    exit 1
fi

fcc=${1}
ign=$(echo ${1} | sed 's/fcc/ign/')

podman pull quay.io/coreos/fcct:release
podman run -i --rm quay.io/coreos/fcct:release --pretty --strict < ${fcc} > ${ign}
