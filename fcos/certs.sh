#!/bin/sh
set -x
set -e

if [ -d certs ]; then
	echo "folder certs exists"
	exit 1
fi

mkdir certs
pushd certs

# copy openssl config

cp ../openssl.cnf .
cp ../worker-openssl.cnf .

# generate certs

## generate root ca
openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"

## generate api server cert
openssl genrsa -out apiserver-key.pem 2048

export MASTER_IP=192.168.122.42 

openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config openssl.cnf
openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 365 -extensions v3_req -extfile openssl.cnf

## generate worker cert

export WORKER_FQDN="fcos-worker"
export WORKER_IP=192.168.122.15

openssl genrsa -out ${WORKER_FQDN}-worker-key.pem 2048
openssl req -new -key ${WORKER_FQDN}-worker-key.pem -out ${WORKER_FQDN}-worker.csr -subj "/CN=${WORKER_FQDN}" -config worker-openssl.cnf
openssl x509 -req -in ${WORKER_FQDN}-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out ${WORKER_FQDN}-worker.pem -days 365 -extensions v3_req -extfile worker-openssl.cnf

## generate cluster administration keypair
openssl genrsa -out admin-key.pem 2048
openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=kube-admin"
openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 365

popd
