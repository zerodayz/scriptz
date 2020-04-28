#!/bin/sh
set -x
set -e

CA_CN="Kube CA"
DOMAIN=
OPENSSL_CNF=/etc/pki/tls/openssl.cnf

if [ -d certs ]; then
	echo "folder certs exists"
	exit 1
fi

mkdir certs
pushd certs

# generate certs

## generate root ca
openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"

## generate api server cert
openssl genrsa -out apiserver-key.pem 2048
openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config openssl.cnf
openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 365 -extensions v3_req -extfile openssl.cnf

