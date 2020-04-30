#!/bin/bash

git clone  https://github.com/zerodayz/filetranspiler.git filetranspiler
pushd filetranspiler
podman build . -t filetranspiler:latest
popd
rm -Rf filetranspiler
