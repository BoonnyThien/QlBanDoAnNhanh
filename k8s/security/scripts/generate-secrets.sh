#!/bin/bash

echo "🔧 Đang tạo file secrets.yaml với giá trị base64..."

# Xóa Secret mysql-secret nếu tồn tại để tránh nhầm lẫn
kubectl delete secret mysql-secret -n default 2>/dev/null || true

# Tạo file secrets.yaml
cat <<EOF > k8s/security/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secrets
  namespace: default
type: Opaque
data:
  MYSQL_ROOT_PASSWORD: $(echo -n 'rootpass' | base64)
  MYSQL_DATABASE: $(echo -n 'qlbandoannhanh' | base64)
  MYSQL_USER: $(echo -n 'app_user' | base64)
  MYSQL_PASSWORD: $(echo -n 'userpass' | base64)
---
apiVersion: v1
kind: Secret
metadata:
  name: php-app-secrets
  namespace: default
type: Opaque
data:
  DB_HOST: $(echo -n 'mysql-service' | base64)
  DB_NAME: $(echo -n 'qlbandoannhanh' | base64)
  DB_USER: $(echo -n 'app_user' | base64)
  DB_PASSWORD: $(echo -n 'userpass' | base64)
  APP_KEY: $(echo -n 'appkey' | base64)
---
apiVersion: v1
kind: Secret
metadata:
  name: php-admin-secrets
  namespace: default
type: Opaque
data:
  DB_HOST: $(echo -n 'mysql-service' | base64)
  DB_NAME: $(echo -n 'qlbandoannhanh' | base64)
  DB_USER: $(echo -n 'app_user' | base64)
  DB_PASSWORD: $(echo -n 'userpass' | base64)
  APP_KEY: $(echo -n 'admin_appkey' | base64)  # Khóa riêng cho php-admin
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-secrets
  namespace: default
type: Opaque
data:
  CF_TUNNEL_CREDENTIALS: $(echo -n '{"AccountTag":"your-account-tag","TunnelSecret":"your-tunnel-secret","TunnelID":"1234-5678-9012"}' | base64)  # Thay bằng credentials thực
EOF

echo "✅ Đã tạo file secrets.yaml với giá trị base64 thực tế:"
cat k8s/security/secrets.yaml

echo "🔄 Áp dụng secrets.yaml vào Kubernetes..."
if kubectl apply -f k8s/security/secrets.yaml; then
  echo "✅ Hoàn tất tạo và áp dụng Secrets!"
else
  echo "❌ Lỗi khi áp dụng Secrets!"
  exit 1
fi