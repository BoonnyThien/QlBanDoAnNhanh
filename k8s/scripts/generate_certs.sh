#!/bin/bash

echo "🔐 Bắt đầu tạo TLS certificates..."

# Tạo thư mục cho certificates
mkdir -p certs
cd certs

# Tạo CA private key và certificate
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 -out ca.crt \
    -subj "/CN=Kubernetes-CA"

# Tạo server key và CSR
openssl genrsa -out server.key 4096
openssl req -new -key server.key -out server.csr \
    -subj "/CN=kubernetes.default.svc"

# Tạo server certificate
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out server.crt -days 365 -sha256

# Tạo Kubernetes secret cho certificates
kubectl create secret tls tls-secret \
    --cert=server.crt \
    --key=server.key \
    --namespace=default

echo "✅ Hoàn tất tạo TLS certificates!"