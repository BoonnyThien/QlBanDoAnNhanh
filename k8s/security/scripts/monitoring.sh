#!/bin/bash

echo "🚀 8 Thiết lập monitoring..."

# Kiểm tra kết nối mạng
echo "🔍 Kiểm tra kết nối đến Helm repository..."
if curl -s --connect-timeout 10 https://prometheus-community.github.io/helm-charts/index.yaml > /dev/null; then
  echo "✅ Kết nối thành công!"
else
  echo "❌ Không thể kết nối đến prometheus-community Helm repo! Kiểm tra mạng hoặc thử lại sau."
  exit 1
fi

# Thêm Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
if [ $? -eq 0 ]; then
  echo "✅ Thêm Helm repo prometheus-community thành công!"
else
  echo "❌ Lỗi khi thêm Helm repo!"
  exit 1
fi

helm repo update
if [ $? -eq 0 ]; then
  echo "✅ Cập nhật Helm repo thành công!"
else
  echo "❌ Lỗi khi cập nhật Helm repo!"
  exit 1
fi

# Tải chart cục bộ nếu chưa có
CHART_DIR="/tmp/kube-prometheus-stack"
if [ ! -d "$CHART_DIR" ]; then
  echo "🔧 Tải chart kube-prometheus-stack cục bộ..."
  helm pull prometheus-community/kube-prometheus-stack --version 62.4.0 --destination /tmp
  tar -xzf /tmp/kube-prometheus-stack-62.4.0.tgz -C /tmp
fi

# Cài Prometheus Operator bằng Helm với timeout tăng
helm install prometheus-operator $CHART_DIR --namespace default --set prometheusOperator.createCustomResource=false --timeout 10m
if [ $? -eq 0 ]; then
  echo "✅ Cài Prometheus Operator thành công!"
else
  echo "❌ Lỗi khi cài Prometheus Operator!"
  exit 1
fi

# Áp dụng ServiceMonitor
cat << EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: php-app-monitor
  namespace: default
spec:
  selector:
    matchLabels:
      app: php-app
  endpoints:
  - port: http
    path: /metrics
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: php-admin-monitor
  namespace: default
spec:
  selector:
    matchLabels:
      app: php-admin
  endpoints:
  - port: http
    path: /metrics
EOF

echo "✅ Hoàn tất thiết lập monitoring!"