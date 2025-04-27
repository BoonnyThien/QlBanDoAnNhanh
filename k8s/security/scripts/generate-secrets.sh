#!/bin/bash

echo "🔧 Đang tạo file secrets.yaml với giá trị base64..."

# Xóa secrets cũ nếu tồn tại
kubectl delete secret mysql-secrets php-app-secrets php-admin-secrets cloudflare-secrets -n default --ignore-not-found

# Tạo giá trị base64 cho CF_TUNNEL_CREDENTIALS và đảm bảo trên một dòng
CF_TUNNEL_CREDENTIALS=$(echo -n '{"AccountTag":"your-account-tag","TunnelSecret":"your-tunnel-secret","TunnelID":"1234-5678-9012"}' | base64 -w 0)

# Tạo file secrets.yaml
cat << EOF > k8s/security/secrets.yaml
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
  APP_KEY: $(echo -n 'admin_appkey' | base64)
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-secrets
  namespace: default
type: Opaque
data:
  CF_TUNNEL_CREDENTIALS: $CF_TUNNEL_CREDENTIALS
EOF

# Kiểm tra cú pháp YAML
if command -v yamllint &> /dev/null; then
  if yamllint k8s/security/secrets.yaml; then
    echo "✅ Cú pháp YAML hợp lệ!"
  else
    echo "❌ Lỗi cú pháp YAML trong secrets.yaml!"
    exit 1
  fi
else
  echo "⚠️ yamllint không được cài đặt, bỏ qua kiểm tra cú pháp."
  # Kiểm tra thủ công bằng kubectl
  if kubectl apply -f k8s/security/secrets.yaml --dry-run=client; then
    echo "✅ Cú pháp YAML hợp lệ (kiểm tra bằng kubectl dry-run)!"
  else
    echo "❌ Lỗi cú pháp YAML trong secrets.yaml!"
    exit 1
  fi
fi

echo "✅ Đã tạo file secrets.yaml với giá trị base64 thực tế:"
cat k8s/security/secrets.yaml

echo "🔄 Áp dụng secrets.yaml vào Kubernetes..."
if kubectl apply -f k8s/security/secrets.yaml; then
  echo "✅ Secrets đã được áp dụng thành công!"
else
  echo "❌ Lỗi khi áp dụng Secrets!"
  exit 1
fi