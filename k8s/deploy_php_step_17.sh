#!/bin/bash

# 17. Tạo và truy cập dịch vụ php-service
echo "🚀 [17] Tạo và truy cập dịch vụ php-service..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi tạo dịch vụ
echo "🔍 Kiểm tra trạng thái pod PHP trước khi tạo dịch vụ..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng để tạo dịch vụ."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

# Kiểm tra xem dịch vụ php-service đã tồn tại chưa
echo "🔍 Kiểm tra xem dịch vụ php-service đã tồn tại chưa..."
kubectl get service php-service -n default >/dev/null 2>&1 || {
  echo "🔍 Dịch vụ php-service chưa tồn tại. Tạo dịch vụ với type NodePort..."
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
}

# Kiểm tra lại dịch vụ sau khi tạo
echo "🔍 Kiểm tra dịch vụ php-service..."
kubectl get service php-service -n default >/dev/null 2>&1 || {
  echo "❌ Không thể tạo dịch vụ php-service."
  echo "🔍 Danh sách dịch vụ:"
  kubectl get service -n default
  echo "🔍 Chi tiết deployment:"
  kubectl describe deployment php-deployment
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Lấy URL của dịch vụ
echo "🔍 Thông tin truy cập dịch vụ..."
minikube service php-service -n default --url || {
  echo "❌ Không thể truy cập dịch vụ php-service."
  echo "🔍 Danh sách dịch vụ trong Minikube:"
  minikube service list
  exit 1
}

echo "✅ [17] Tạo và truy cập dịch vụ php-service hoàn tất."