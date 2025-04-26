#!/bin/bash

echo "🔐 Bắt đầu tạo TLS certificates..."

# Tạo thư mục cho certificates
mkdir -p certs
cd certs

# Tạo CA private key và certificate
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 -out ca.crt \
    -subj "/CN=Kubernetes-CA"

# Tạo server key và CSR cho kubernetes.default.svc (dùng cho MySQL)
openssl genrsa -out server.key 4096
openssl req -new -key server.key -out server.csr \
    -subj "/CN=kubernetes.default.svc"

# Tạo server certificate
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out server.crt -days 365 -sha256

# Tạo Kubernetes secret cho certificates
if kubectl create secret tls tls-secret \
    --cert=server.crt \
    --key=server.key \
    --namespace=default; then
  echo "✅ Tạo secret tls-secret thành công!"
else
  echo "❌ Lỗi khi tạo secret tls-secret!"
  exit 1
fi

# Tạo chứng chỉ cho Cloudflare Tunnel (tùy chọn, nếu không dùng SSL từ Cloudflare)
openssl genrsa -out app.key 4096
openssl req -new -key app.key -out app.csr \
    -subj "/CN=app.yourdomain.com"
openssl x509 -req -in app.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out app.crt -days 365 -sha256
kubectl create secret tls app-tls \
    --cert=app.crt \
    --key=app.key \
    --namespace=default

openssl genrsa -out admin.key 4096
openssl req -new -key admin.key -out admin.csr \
    -subj "/CN=admin.yourdomain.com"
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out admin.crt -days 365 -sha256
kubectl create secret tls admin-tls \
    --cert=admin.crt \
    --key=admin.key \
    --namespace=default

echo "✅ Hoàn tất tạo TLS certificates!"