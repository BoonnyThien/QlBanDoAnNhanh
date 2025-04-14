#!/bin/bash

# 16.1. Cấu hình ServerName cho Apache
echo "🚀 [16.1] Cấu hình ServerName cho Apache..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi cấu hình
echo "🔍 Kiểm tra trạng thái pod PHP trước khi cấu hình ServerName..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng để cấu hình ServerName."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

# Kiểm tra xem ServerName đã được cấu hình chưa
echo "🔍 Kiểm tra cấu hình ServerName trong apache2.conf..."
kubectl exec $php_pod --container php -- bash -c "grep 'ServerName' /etc/apache2/apache2.conf" || {
  echo "⚠️ Không tìm thấy cấu hình ServerName trong /etc/apache2/apache2.conf. Thêm cấu hình..."
  kubectl exec $php_pod --container php -- bash -c "echo 'ServerName localhost' | sudo tee -a /etc/apache2/apache2.conf" || {
    echo "❌ Không thể thêm ServerName vào apache2.conf."
    echo "🔍 Log của pod PHP:"
    kubectl logs $php_pod
    exit 1
  }
}

# Xác nhận lại cấu hình ServerName
echo "🔍 Xác nhận cấu hình ServerName..."
kubectl exec $php_pod --container php -- bash -c "grep 'ServerName' /etc/apache2/apache2.conf" || {
  echo "❌ Cấu hình ServerName không được áp dụng."
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

echo "✅ [16.1] Cấu hình ServerName cho Apache hoàn tất."