#!/bin/sh
set -x
set -e

CA_CN="Local Eclipse Che Signer"
DOMAIN=
OPENSSL_CNF=/etc/pki/tls/openssl.cnf

if [ -d certs ]; then
	echo "folder certs exists"
	exit 1
fi

mkdir certs
pushd certs

# generate certs

openssl genrsa -out ca.key 4096
openssl req -x509 \
  -new -nodes \
  -key ca.key \
  -sha256 \
  -days 1024 \
  -out ca.crt \
  -subj /CN="${CA_CN}" \
  -reqexts SAN \
  -extensions SAN \
  -config <(cat ${OPENSSL_CNF} \
      <(printf '[SAN]\nbasicConstraints=critical, CA:TRUE\nkeyUsage=keyCertSign, cRLSign, digitalSignature'))

openssl genrsa -out domain.key 2048
openssl req -new -sha256 \
    -key domain.key \
    -subj "/O=Local {prod}/CN=${DOMAIN}" \
    -reqexts SAN \
    -config <(cat ${OPENSSL_CNF} \
        <(printf "\n[SAN]\nsubjectAltName=DNS:${DOMAIN}\nbasicConstraints=critical, CA:FALSE\nkeyUsage=digitalSignature, keyEncipherment, keyAgreement, dataEncipherment\nextendedKeyUsage=serverAuth")) \
    -out domain.csr

openssl x509 \
    -req \
    -sha256 \
    -extfile <(printf "subjectAltName=DNS:${DOMAIN}\nbasicConstraints=critical, CA:FALSE\nkeyUsage=digitalSignature, keyEncipherment, keyAgreement, dataEncipherment\nextendedKeyUsage=serverAuth") \
    -days 365 \
    -in domain.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial -out domain.crt

popd

kubectl create secret tls che-tls --key=certs/domain.key --cert=certs/domain.crt -n che
kubectl create secret generic self-signed-certificate --from-file=certs/ca.crt -n che
chectl server:start --platform=k8s --installer=operator --self-signed-cert --domain <cluster-domain>
