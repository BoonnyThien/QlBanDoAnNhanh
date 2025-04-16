#!/bin/bash

set -e

echo "🚀 [17] Tạo và truy cập dịch vụ php-service..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt 2>/dev/null || echo "")
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod
echo "🔍 Kiểm tra trạng thái pod PHP trước khi tạo dịch vụ..."
php_status=$(kubectl get pod "$php_pod" -o jsonpath='{.status.phase}' -n default 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod "$php_pod" -o jsonpath='{.status.containerStatuses[0].ready}' -n default 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng."
  kubectl describe pod "$php_pod" -n default
  kubectl logs "$php_pod" -n default 2>/dev/null || echo "⚠️ Không thể lấy log."
  exit 1
fi

# Tạo dịch vụ php-service
echo "🔍 Tạo dịch vụ php-service với type NodePort..."
kubectl delete service php-service -n default --ignore-not-found
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: php-service
  namespace: default
spec:
  selector:
    app: php
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080
  type: NodePort
EOF

# Kiểm tra dịch vụ
echo "🔍 Kiểm tra dịch vụ php-service..."
kubectl get service php-service -n default >/dev/null 2>&1 || {
  echo "❌ Không thể tạo dịch vụ php-service."
  kubectl get service -n default
  exit 1
}

# Lấy URL và kiểm tra kết nối
echo "🔍 Kiểm tra kết nối đến dịch vụ..."
service_url=$(minikube service php-service -n default --url | head -n 1)
if curl --connect-timeout 5 "$service_url" >/dev/null 2>&1; then
  echo "✅ Kết nối đến $service_url thành công."
else
  echo "❌ Không thể truy cập $service_url."
  kubectl logs "$php_pod" -n default 2>/dev/null || echo "⚠️ Không thể lấy log."
  exit 1
fi

echo "✅ [17] Tạo và truy cập dịch vụ php-service hoàn tất."
echo "🔗 Truy cập tại: $service_url"