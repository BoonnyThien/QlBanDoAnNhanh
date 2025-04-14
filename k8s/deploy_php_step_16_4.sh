#!/bin/bash

# 16.4. Khởi động lại pod PHP để áp dụng cấu hình
echo "🚀 [16.4] Khởi động lại pod PHP..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi khởi động lại
echo "🔍 Kiểm tra trạng thái pod PHP trước khi khởi động lại..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng để khởi động lại."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

# Khởi động lại pod để áp dụng thay đổi
echo "🔍 Khởi động lại pod PHP để áp dụng cấu hình..."
kubectl delete pod $php_pod --force --grace-period=0
echo "🔍 Đợi pod PHP khởi động lại..."
kubectl rollout status deployment/php-deployment --timeout=120s || {
  echo "❌ Pod PHP không sẵn sàng sau khi khởi động lại."
  echo "🔍 Chi tiết deployment:"
  kubectl describe deployment php-deployment
  echo "🔍 Log của pod PHP:"
  kubectl logs -l app=php
  exit 1
}

# Lấy tên pod mới sau khi khởi động lại
echo "🔍 Lấy tên pod PHP mới..."
php_pod=$(kubectl get pods -l app=php -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy pod PHP sau khi khởi động lại."
  echo "🔍 Danh sách pod:"
  kubectl get pods -l app=php
  exit 1
fi

# Kiểm tra trạng thái pod sau khi khởi động lại
echo "🔍 Kiểm tra trạng thái pod PHP sau khi khởi động lại..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng sau khi khởi động lại."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

# Cập nhật tên pod mới vào file tạm
echo "$php_pod" > /tmp/php_pod_name.txt

# Kiểm tra log Apache để xác nhận không có cảnh báo ServerName
echo "🔍 Kiểm tra log Apache để xác nhận không có cảnh báo ServerName..."
kubectl exec $php_pod --container php -- bash -c "test -f /var/log/apache2/error.log && echo 'File log tồn tại' || echo 'File log không tồn tại'" || {
  echo "⚠️ Không thể kiểm tra file log Apache."
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
}

kubectl --request-timeout=10s exec $php_pod --container php -- bash -c "tail -n 100 /var/log/apache2/error.log 2>/dev/null | grep -i 'ServerName' || echo 'Không có cảnh báo ServerName.'" || {
  echo "⚠️ Vẫn có cảnh báo ServerName trong log Apache hoặc không thể đọc log."
  echo "🔍 Nội dung file apache2.conf:"
  kubectl exec $php_pod --container php -- cat /etc/apache2/apache2.conf | grep ServerName
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
}

echo "✅ [16.4] Khởi động lại pod PHP hoàn tất."
echo "✅ Đoạn 16 hoàn tất: Cấu hình Apache và kiểm tra module PDO hoàn tất."