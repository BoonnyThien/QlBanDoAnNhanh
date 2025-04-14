#!/bin/bash

# 16.2. Đảm bảo module mod_rewrite được bật
echo "🚀 [16.2] Đảm bảo module mod_rewrite được bật..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi bật module
echo "🔍 Kiểm tra trạng thái pod PHP trước khi bật module mod_rewrite..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng để bật module mod_rewrite."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

# Đảm bảo module mod_rewrite được bật
echo "🔍 Đảm bảo module mod_rewrite được bật..."
kubectl exec $php_pod --container php -- bash -c "sudo a2enmod rewrite" || {
  echo "❌ Không thể bật module mod_rewrite."
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Kiểm tra xem module mod_rewrite đã được bật chưa
echo "🔍 Kiểm tra trạng thái module mod_rewrite..."
kubectl exec $php_pod --container php -- bash -c "apache2ctl -M | grep rewrite" || {
  echo "❌ Module mod_rewrite không được bật."
  echo "🔍 Danh sách module Apache:"
  kubectl exec $php_pod --container php -- apache2ctl -M
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

echo "✅ [16.2] Đảm bảo module mod_rewrite được bật hoàn tất."