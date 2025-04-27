#!/bin/bash

echo "🔍 Bắt đầu kiểm tra bảo mật hệ thống QLBandoannhanh..."

# 1. Kiểm tra tổng quan hệ thống
echo "🚀 1 Kiểm tra tổng quan hệ thống..."
minikube status
echo "🔹 Pods của php-app và mysql:"
kubectl get pods -n default -l app=php-app
kubectl get pods -n default -l app=mysql
echo ""

# 2. Kiểm tra RBAC
chmod +x k8s/security/scripts/check_rbac.sh
./k8s/security/scripts/check_rbac.sh

# 3. Kiểm tra Network Policies
chmod +x k8s/security/scripts/check_network_policie.sh
./k8s/security/scripts/check_network_policie.sh


# 4. Kiểm tra Secrets
chmod +x k8s/security/scripts/check_secrets.sh
./k8s/security/scripts/check_secrets.sh

# 5. Kiểm tra Container Security
chmod +x k8s/security/scripts/check_container_security.sh
./k8s/security/scripts/check_container_security.sh

# 6. Kiểm tra TLS Certificates
chmod +x k8s/security/scripts/check_generate_certs.sh
./k8s/security/scripts/check_generate_certs.sh

# 7. Kiểm tra MySQL Hardening
chmod +x k8s/security/scripts/check_secure_mysql.sh
./k8s/security/scripts/check_secure_mysql.sh

# 8. Kiểm tra Auth Service
chmod +x k8s/security/scripts/check_auth_service.sh
./k8s/security/scripts/check_auth_service.sh

# 9. Kiểm tra Monitoring
chmod +x k8s/security/scripts/check_monitoring.sh
./k8s/security/scripts/check_monitoring.sh

# 10. Kiểm tra Backup
chmod +x k8s/security/scripts/check_velero.sh
./k8s/security/scripts/check_velero.sh

# 11. Kiểm tra Falco
chmod +x k8s/security/scripts/check_falco.sh
./k8s/security/scripts/check_falco.sh

# 12. Kiểm tra Audit Logs
# chmod +x k8s/security/scripts/check_audit_logs.sh
# ./k8s/security/scripts/check_audit_logs.sh

# # 13. Kiểm tra Key Rotation
# chmod +x k8s/security/scripts/check_rotation_keys_secrets.sh
# ./k8s/security/scripts/check_rotation_keys_secrets.sh

# # 14. Áp dụng CronJob cho Key Rotation (nếu chưa tồn tại)
# chmod +x k8s/security/scripts/check_key_rotation_cronjob.sh
# ./k8s/security/scripts/check_key_rotation_cronjob.sh
# # 15 ThưKiểm tra trạng thái tổng thể

chmod +x k8s/security/scripts/check_all.sh
./k8s/security/scripts/check_all.sh