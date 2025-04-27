#!/bin/bash

echo "🔒 Bắt đầu thiết lập bảo mật MySQL..."

# Xóa ConfigMap cũ nếu tồn tại
kubectl delete configmap mysql-security-config -n default --ignore-not-found

# Tạo ConfigMap cho cấu hình bảo mật MySQL
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-security-config
  namespace: default
data:
  my.cnf: |
    [mysqld]
    ssl-ca=/etc/mysql/certs/ca.crt
    ssl-cert=/etc/mysql/certs/tls.crt
    ssl-key=/etc/mysql/certs/tls.key
    max_connections=100
    slow_query_log=1
    slow_query_log_file=/var/log/mysql/slow.log
    long_query_time=1
EOF

if [ $? -eq 0 ]; then
  echo "✅ Tạo ConfigMap mysql-security-config thành công!"
else
  echo "❌ Lỗi khi tạo ConfigMap!"
  exit 1
fi

# Kiểm tra xem Deployment mysql tồn tại
if kubectl get deployment mysql -n default &> /dev/null; then
  # Khởi động lại MySQL Deployment với timestamp Unix
  TIMESTAMP=$(date +%s)
  kubectl patch deployment mysql -n default -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"restartTimestamp\":\"$TIMESTAMP\"}}}}}"
  if [ $? -eq 0 ]; then
    echo "✅ Khởi động lại Deployment mysql thành công!"
  else
    echo "❌ Lỗi khi khởi động lại Deployment mysql!"
    exit 1
  fi
else
  echo "❌ Deployment mysql không tồn tại!"
  exit 1
fi

echo "✅ Hoàn tất thiết lập bảo mật MySQL!"