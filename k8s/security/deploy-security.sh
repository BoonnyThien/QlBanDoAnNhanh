#!/bin/bash

echo "🔒 Thiết lập bảo mật cho hệ thống..."

# 1. Thiết lập RBAC
echo "🚀 1 Áp dụng RBAC..."
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

# 8. Thiết lập monitoring
echo "🚀 8 Thiết lập monitoring..."
if kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.75.2/bundle.yaml; then
  echo "✅ Cài Prometheus Operator thành công!"
else
  echo "❌ Lỗi khi cài Prometheus Operator!"
  exit 1
fi
sleep 10  # Đợi CRD sẵn sàng
if kubectl apply -f k8s/security/monitoring.yaml; then
  echo "✅ Monitoring áp dụng thành công!"
else
  echo "❌ Lỗi khi áp dụng monitoring!"
  exit 1
fi

# 9. Cài đặt và thiết lập backup với Velero
echo "🚀 9.1 Thiết lập backup với Velero..."
if velero backup create doannhanh-backup --include-namespaces default; then
  echo "✅ Tạo backup doannhanh-backup thành công!"
else
  echo "❌ Lỗi khi tạo backup!"
  exit 1
fi

# 10. Thiết lập Falco (phát hiện xâm nhập runtime)
echo "🚀 10 Thiết lập Falco..."
kubectl create namespace falco --dry-run=client -o yaml | kubectl apply -f -
if kubectl apply -f k8s/security/falco.yaml; then
  echo "✅ Falco triển khai thành công!"
else
  echo "❌ Lỗi khi triển khai Falco!"
  exit 1
fi
sleep 5

# 11. Thiết lập audit logging
echo "🚀 11 Thiết lập audit logging..."
# Lưu audit-policy.yaml vào /mnt/audit-policy.yaml trong Minikube
minikube ssh "sudo mkdir -p /mnt && sudo tee /mnt/audit-policy.yaml > /dev/null <<EOF
$(cat k8s/security/audit-policy.yaml)
EOF"
# Restart Minikube với audit logging
minikube stop
if minikube start --extra-config=apiserver.audit-policy-file=/mnt/audit-policy.yaml --extra-config=apiserver.audit-log-path=/var/log/kubernetes/audit.log; then
  echo "✅ Audit logging thiết lập thành công!"
else
  echo "❌ Lỗi khi thiết lập audit logging!"
  exit 1
fi

echo "🚀 12 Rotation keys cho secrets..."
NEW_PASSWORD=$(openssl rand -base64 12)
if kubectl patch secret mysql-secrets -p "{\"data\":{\"MYSQL_PASSWORD\":\"$(echo -n $NEW_PASSWORD | base64)\"}}"; then
  echo "🔑 Đã cập nhật MYSQL_PASSWORD trong mysql-secrets"
  # Cập nhật php-app-secrets và php-admin-secrets
  kubectl patch secret php-app-secrets -p "{\"data\":{\"DB_PASSWORD\":\"$(echo -n $NEW_PASSWORD | base64)\"}}"
  kubectl patch secret php-admin-secrets -p "{\"data\":{\"DB_PASSWORD\":\"$(echo -n $NEW_PASSWORD | base64)\"}}"
  # Restart Deployments
  kubectl rollout restart deployment php-app php-admin mysql
  echo "✅ Đã restart Deployments để áp dụng password mới!"
else
  echo "❌ Lỗi khi cập nhật MYSQL_PASSWORD!"
  exit 1
fi

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