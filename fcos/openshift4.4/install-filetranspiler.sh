#!/bin/bash

git clone git@github.com:zerodayz/filetranspiler.git filetranspiler
pushd filetranspiler
podman build . -t filetranspiler:latest
popd
rm -Rf filetranspiler
