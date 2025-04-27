#!/bin/bash

echo "🔒 Thiết lập bảo mật cho hệ thống..."

# 1. Thiết lập RBAC
echo "🚀 1 Áp dụng RBAC..."

# Xóa các tài nguyên RBAC cũ nếu tồn tại
kubectl delete -f k8s/security/rbac.yaml --ignore-not-found
if [ $? -eq 0 ]; then
  echo "✅ Đã xóa các tài nguyên RBAC cũ (nếu có)!"
else
  echo "❌ Lỗi khi xóa các tài nguyên RBAC cũ!"
  exit 1
fi

# Áp dụng lại rbac.yaml
kubectl apply -f k8s/security/rbac.yaml
if [ $? -eq 0 ]; then
  echo "✅ RBAC áp dụng thành công!"
else
  echo "❌ Lỗi khi áp dụng RBAC!"
  exit 1
fi

# 2. Áp dụng Network Policies
echo "🚀 2 Áp dụng Network Policies..."
kubectl apply -f k8s/security/network-policies.yaml
if [ $? -eq 0 ]; then
  echo "✅ Network Policies áp dụng thành công!"
else
  echo "❌ Lỗi khi áp dụng Network Policies!"
  exit 1
fi
# 3. Áp dụng Secrets
echo "🚀 3 Áp dụng Secrets..."
chmod +x k8s/security/scripts/generate-secrets.sh
./k8s/security/scripts/generate-secrets.sh

# 4. Quét bảo mật container
echo "🚀 4 Quét bảo mật container..."
chmod +x k8s/security/scripts/scan_images.sh
./k8s/security/scripts/scan_images.sh

# 5. Tạo và áp dụng TLS certificates
echo "🚀 5 Tạo và áp dụng TLS certificates..."
chmod +x k8s/security/scripts/generate_certs.sh
./k8s/security/scripts/generate_certs.sh

# 6. Hardening MySQL
echo "🚀 6 Hardening MySQL..."
chmod +x k8s/security/scripts/secure_mysql.sh
./k8s/security/scripts/secure_mysql.sh

# 7. Triển khai auth-service
echo "🚀 7 Triển khai auth-service..."
if kubectl apply -f k8s/security/auth-service.yaml; then
  echo "✅ Auth-service triển khai thành công!"
else
  echo "❌ Lỗi khi triển khai auth-service!"
  exit 1
fi

chmod +x k8s/security/scripts/monitoring.sh
./k8s/security/scripts/monitoring.sh

# 9. Cài đặt và thiết lập backup với Velero
chmod +x k8s/security/scripts/setup-velero.sh
./k8s/security/scripts/setup-velero.sh

# 10. Thiết lập Falco (phát hiện xâm nhập runtime)
chmod +x k8s/security/scripts/setup-falco.sh
./k8s/security/scripts/setup-falco.sh

# 11. Thiết lập audit logging
# echo "🚀 11 Thiết lập audit logging..."
# chmod +x k8s/security/scripts/setup-audit-logging.sh
# ./k8s/security/scripts/setup-audit-logging.sh

# echo "🚀 12 Rotation keys cho secrets..."
# NEW_PASSWORD=$(openssl rand -base64 12)
# if kubectl patch secret mysql-secrets -p "{\"data\":{\"MYSQL_PASSWORD\":\"$(echo -n $NEW_PASSWORD | base64)\"}}"; then
#   echo "🔑 Đã cập nhật MYSQL_PASSWORD trong mysql-secrets"
#   # Cập nhật php-app-secrets và php-admin-secrets
#   kubectl patch secret php-app-secrets -p "{\"data\":{\"DB_PASSWORD\":\"$(echo -n $NEW_PASSWORD | base64)\"}}"
#   kubectl patch secret php-admin-secrets -p "{\"data\":{\"DB_PASSWORD\":\"$(echo -n $NEW_PASSWORD | base64)\"}}"
#   # Restart Deployments
#   kubectl rollout restart deployment php-app php-admin mysql
#   echo "✅ Đã restart Deployments để áp dụng password mới!"
# else
#   echo "❌ Lỗi khi cập nhật MYSQL_PASSWORD!"
#   exit 1
# fi

# 13. Kiểm tra trạng thái sau khi triển khai
echo "🚀 13 Kiểm tra trạng thái..."
echo "🔍 Pods:"
kubectl get pods -n default
kubectl get pods -n velero
kubectl get pods -n falco
echo "🔍 Secrets:"
kubectl get secrets -n default
echo "🔍 Network Policies:"
kubectl get networkpolicies -n default
echo "🔍 Service Monitors:"
kubectl get servicemonitors

echo "✅ Hoàn tất thiết lập bảo mật!"