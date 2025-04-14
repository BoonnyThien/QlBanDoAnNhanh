#!/bin/bash

# 12.5. Kiểm tra extension pdo_mysql cho PHP
echo "🚀 [12.5] Kiểm tra extension pdo_mysql cho PHP..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi kiểm tra extension
echo "🔍 Kiểm tra trạng thái pod PHP trước khi kiểm tra extension..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng để kiểm tra extension."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

# Kiểm tra xem extension pdo_mysql đã được cài đặt chưa
echo "🔍 Kiểm tra extension pdo_mysql..."
if kubectl exec $php_pod --container php -- php -m | grep -q pdo_mysql; then
  echo "✅ Extension pdo_mysql đã được cài đặt sẵn trong image."
else
  echo "❌ Extension pdo_mysql chưa được cài đặt trong image."
  echo "🔍 Danh sách module PHP:"
  kubectl exec $php_pod --container php -- php -m
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

echo "✅ [12.5] Kiểm tra extension pdo_mysql cho PHP hoàn tất."