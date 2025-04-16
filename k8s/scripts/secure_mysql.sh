#!/bin/bash

echo "🔒 Bắt đầu thiết lập bảo mật MySQL..."

# Lấy tên pod MySQL
MYSQL_POD=$(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}')

# Tạo file cấu hình MySQL security
cat << EOF > mysql-security.cnf
[mysqld]
# Bảo mật cơ bản
bind-address = 0.0.0.0
skip-symbolic-links
secure-file-priv=/var/lib/mysql-files

# Mã hóa kết nối
require_secure_transport = ON
ssl-cert=/etc/mysql/ssl/server-cert.pem
ssl-key=/etc/mysql/ssl/server-key.pem

# Giới hạn truy cập
max_connect_errors = 10
max_connections = 100

# Logging
log_error = /var/log/mysql/error.log
general_log = 0
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
EOF

# Tạo ConfigMap từ file cấu hình
kubectl create configmap mysql-security-config --from-file=mysql-security.cnf -n default

# Cập nhật MySQL pod để sử dụng cấu hình mới
kubectl set volume deployment/mysql --add -t configmap \
    --configmap-name=mysql-security-config \
    --mount-path=/etc/mysql/conf.d/security.cnf \
    --sub-path=mysql-security.cnf

# Khởi động lại pod MySQL
kubectl rollout restart deployment mysql

echo "✅ Hoàn tất thiết lập bảo mật MySQL!"