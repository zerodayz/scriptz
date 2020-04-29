#!/bin/bash

if [ -d images ]; then
    echo "Directory images already exists."
    exit 1
fi
mkdir images
pushd images
curl 'https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/31.20191210.3.0/x86_64/fedora-coreos-31.20191210.3.0-installer-kernel-x86_64' -o fedora-coreos-31.20191210.3.0-installer-kernel-x86_64
curl 'https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/31.20191210.3.0/x86_64/fedora-coreos-31.20191210.3.0-installer-initramfs.x86_64.img' -o fedora-coreos-31.20191210.3.0-installer-initramfs.x86_64.img
curl 'https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/31.20191210.3.0/x86_64/fedora-coreos-31.20191210.3.0-metal.x86_64.raw.xz' -o fedora-coreos-31.20191210.3.0-metal.x86_64.raw.xz
curl 'https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/31.20191210.3.0/x86_64/fedora-coreos-31.20191210.3.0-installer.x86_64.iso' -o fedora-coreos-31.20191210.3.0-installer.x86_64.iso
popd
