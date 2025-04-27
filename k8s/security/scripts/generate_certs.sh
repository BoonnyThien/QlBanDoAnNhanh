#!/bin/bash

echo "🔐 Bắt đầu tạo TLS certificates..."

# Xóa secrets cũ nếu tồn tại
kubectl delete secret tls-secret app-tls admin-tls -n default --ignore-not-found

# Tạo CA
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=kubernetes.default.svc" -days 3650 -out ca.crt

# Tạo secret cho CA
kubectl create secret generic tls-secret --from-file=tls.crt=ca.crt --from-file=tls.key=ca.key -n default
if [ $? -eq 0 ]; then
  echo "✅ Tạo secret tls-secret thành công!"
else
  echo "❌ Lỗi khi tạo secret tls-secret!"
  exit 1
fi

# Tạo cert cho app
openssl genrsa -out app.key 2048
openssl req -new -key app.key -subj "/CN=app.yourdomain.com" -out app.csr
openssl x509 -req -in app.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out app.crt -days 365
kubectl create secret tls app-tls --cert=app.crt --key=app.key -n default

# Tạo cert cho admin
openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -subj "/CN=admin.yourdomain.com" -out admin.csr
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out admin.crt -days 365
kubectl create secret tls admin-tls --cert=admin.crt --key=admin.key -n default

echo "✅ Hoàn tất tạo TLS certificates!"