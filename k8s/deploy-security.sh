echo "🔒 Thiết lập bảo mật cho hệ thống..."

# 1. Thiết lập RBAC
chmod +x ./k8s/rbac.yaml

kubectl apply -f k8s/rbac.yaml

# 2. Áp dụng Network Policies
chmod +x ./k8s/network-policies.yaml

kubectl apply -f k8s/network-policies.yaml

# 3. Quét bảo mật container
chmod +x ./k8s/scripts/scan_images.sh

./k8s/scripts/scan_images.sh

# 4. Tạo và áp dụng TLS certificates
chmod +x ./k8s/scripts/generate_certs.sh

./k8s/scripts/generate_certs.sh

# 5. Hardening MySQL
chmod +x ./k8s/scripts/secure_mysql.sh

./k8s/scripts/secure_mysql.sh

# 6. Thiết lập monitoring
kubectl apply -f k8s/monitoring.yaml
kubectl apply -f k8s/falco.yaml

# 7. Thiết lập audit logging
kubectl apply -f k8s/audit-policy.yaml

echo "✅ Hoàn tất thiết lập bảo mật!"