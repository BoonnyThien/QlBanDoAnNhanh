#!/bin/bash

echo "🔒 Bắt đầu thiết lập bảo mật MySQL..."

# Tạo file cấu hình MySQL security
cat << EOF > mysql-security.cnf
[mysqld]
# Bảo mật cơ bản
bind-address = 0.0.0.0
skip-symbolic-links = 1
secure-file-priv = /var/lib/mysql-files

# Mã hóa kết nối
require_secure_transport = ON
ssl-cert = /etc/mysql/ssl/tls.crt
ssl-key = /etc/mysql/ssl/tls.key

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

# Tạo ConfigMap
if kubectl create configmap mysql-security-config --from-file=mysql-security.cnf -n default; then
  echo "✅ Tạo ConfigMap mysql-security-config thành công!"
else
  echo "❌ Lỗi khi tạo ConfigMap!"
  exit 1
fi

# Patch Deployment mysql để gắn ConfigMap và Secret TLS
kubectl patch deployment mysql -n default --patch '{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "mysql",
            "volumeMounts": [
              {
                "name": "config",
                "mountPath": "/etc/mysql/conf.d/security.cnf",
                "subPath": "mysql-security.cnf"
              },
              {
                "name": "tls",
                "mountPath": "/etc/mysql/ssl"
              }
            ]
          }
        ],
        "volumes": [
          {
            "name": "config",
            "configMap": {
              "name": "mysql-security-config"
            }
          },
          {
            "name": "tls",
            "secret": {
              "secretName": "tls-secret"
            }
          }
        ]
      }
    }
  }
}'

# Khởi động lại Deployment
if kubectl rollout restart deployment mysql -n default; then
  echo "✅ Khởi động lại Deployment mysql thành công!"
else
  echo "❌ Lỗi khi khởi động lại Deployment!"
  exit 1
fi

echo "✅ Hoàn tất thiết lập bảo mật MySQL!"