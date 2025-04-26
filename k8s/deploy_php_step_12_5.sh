#!/bin/bash

# 12.5. Kiểm tra extension pdo_mysql cho PHP (cả php-app và php-admin)
echo "🚀 [12.5] Kiểm tra extension pdo_mysql cho PHP..."

# Kiểm tra pod PHP (User)
echo "🔍 Kiểm tra pod PHP (User)..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP (User). Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi kiểm tra extension
echo "🔍 Kiểm tra trạng thái pod PHP (User) trước khi kiểm tra extension..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP (User) ($php_pod) không sẵn sàng để kiểm tra extension."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP (User):"
  kubectl logs $php_pod --container php-app
  exit 1
fi

# Kiểm tra xem extension pdo_mysql đã được cài đặt chưa cho php-app
echo "🔍 Kiểm tra extension pdo_mysql cho PHP (User)..."
if kubectl exec $php_pod --container php-app -- php -m | grep -q pdo_mysql; then
  echo "✅ Extension pdo_mysql đã được cài đặt sẵn trong image cho PHP (User)."
else
  echo "❌ Extension pdo_mysql chưa được cài đặt trong image cho PHP (User)."
  echo "🔍 Danh sách module PHP:"
  kubectl exec $php_pod --container php-app -- php -m
  echo "🔍 Log của pod PHP (User):"
  kubectl logs $php_pod --container php-app
  exit 1
fi

# Kiểm tra pod PHP Admin
echo "🔍 Kiểm tra pod PHP Admin..."

# Đọc tên pod từ file tạm
php_admin_pod=$(cat /tmp/php_admin_pod_name.txt)
if [ -z "$php_admin_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP Admin. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi kiểm tra extension
echo "🔍 Kiểm tra trạng thái pod PHP Admin trước khi kiểm tra extension..."
php_admin_status=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_admin_ready=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_admin_status" != "Running" ] || [ "$php_admin_ready" != "true" ]; then
  echo "❌ Pod PHP Admin ($php_admin_pod) không sẵn sàng để kiểm tra extension."
  echo "🔍 Trạng thái pod: $php_admin_status"
  echo "🔍 Trạng thái ready: $php_admin_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_admin_pod
  echo "🔍 Log của pod PHP Admin:"
  kubectl logs $php_admin_pod --container php-admin
  exit 1
fi

# Kiểm tra xem extension pdo_mysql đã được cài đặt chưa cho php-admin
echo "🔍 Kiểm tra extension pdo_mysql cho PHP Admin..."
if kubectl exec $php_admin_pod --container php-admin -- php -m | grep -q pdo_mysql; then
  echo "✅ Extension pdo_mysql đã được cài đặt sẵn trong image cho PHP Admin."
else
  echo "❌ Extension pdo_mysql chưa được cài đặt trong image cho PHP Admin."
  echo "🔍 Danh sách module PHP:"
  kubectl exec $php_admin_pod --container php-admin -- php -m
  echo "🔍 Log của pod PHP Admin:"
  kubectl logs $php_admin_pod --container php-admin
  exit 1
fi

echo "✅ [12.5] Kiểm tra extension pdo_mysql cho PHP hoàn tất."