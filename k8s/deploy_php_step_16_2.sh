#!/bin/bash

# 16.2. Kiểm tra module mod_rewrite
echo "🚀 [16.2] Kiểm tra module mod_rewrite..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi kiểm tra module
echo "🔍 Kiểm tra trạng thái pod PHP trước khi kiểm tra module mod_rewrite..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng để kiểm tra module mod_rewrite."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

# Kiểm tra xem module mod_rewrite đã được bật chưa
echo "🔍 Kiểm tra trạng thái module mod_rewrite..."
if kubectl exec $php_pod --container php -- apache2ctl -M | grep -q rewrite; then
  echo "✅ Module mod_rewrite đã được bật sẵn trong image."
else
  echo "🔍 Module mod_rewrite chưa được bật. Tiến hành bật..."
  kubectl exec $php_pod --container php -- bash -c "sudo a2enmod rewrite" || {
    echo "❌ Không thể bật module mod_rewrite."
    echo "🔍 Log của pod PHP:"
    kubectl logs $php_pod
    exit 1
  }
  # Kiểm tra lại
  if kubectl exec $php_pod --container php -- apache2ctl -M | grep -q rewrite; then
    echo "✅ Module mod_rewrite đã được bật thành công."
  else
    echo "❌ Module mod_rewrite vẫn không được bật."
    echo "🔍 Danh sách module Apache:"
    kubectl exec $php_pod --container php -- apache2ctl -M
    echo "🔍 Log của pod PHP:"
    kubectl logs $php_pod
    exit 1
  fi
fi

echo "✅ [16.2] Kiểm tra module mod_rewrite hoàn tất."