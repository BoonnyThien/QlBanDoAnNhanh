#!/bin/bash

# 16.4. Khởi động lại Apache (graceful reload)
echo "🚀 [16.4] Khởi động lại Apache (graceful reload)..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi khởi động lại Apache
echo "🔍 Kiểm tra trạng thái pod PHP trước khi khởi động lại Apache..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng để khởi động lại Apache."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

# Đợi một chút để đảm bảo container ổn định
echo "🔍 Đợi 5 giây để container ổn định trước khi khởi động lại Apache..."
sleep 5

# Khởi động lại Apache bằng apache2ctl graceful
echo "🔍 Khởi động lại Apache (graceful reload)..."
kubectl exec $php_pod --container php -- bash -c "sudo apache2ctl graceful" || {
  echo "❌ Không thể khởi động lại Apache bằng apache2ctl graceful."
  echo "🔍 Log của Apache:"
  kubectl exec $php_pod --container php -- cat /var/log/apache2/error.log 2>/dev/null || echo "Không thể truy cập log Apache."
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Kiểm tra trạng thái Apache sau khi khởi động lại
echo "🔍 Kiểm tra trạng thái Apache sau khi khởi động lại..."
kubectl exec $php_pod --container php -- bash -c "service apache2 status" || {
  echo "❌ Apache không chạy sau khi khởi động lại."
  echo "🔍 Log của Apache:"
  kubectl exec $php_pod --container php -- cat /var/log/apache2/error.log 2>/dev/null || echo "Không thể truy cập log Apache."
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Kiểm tra trạng thái pod sau khi khởi động lại Apache
echo "🔍 Kiểm tra trạng thái pod PHP sau khi khởi động lại Apache..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng sau khi khởi động lại Apache."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

# Kiểm tra log Apache để xác nhận không có cảnh báo ServerName
echo "🔍 Kiểm tra log Apache để xác nhận không có cảnh báo ServerName..."
# Kiểm tra xem file log có tồn tại không
kubectl exec $php_pod --container php -- bash -c "test -f /var/log/apache2/error.log && echo 'File log tồn tại' || echo 'File log không tồn tại'" || {
  echo "⚠️ Không thể kiểm tra file log Apache."
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
}

# Đọc 100 dòng cuối của file log để giảm thời gian xử lý, với timeout 10 giây
kubectl --request-timeout=10s exec $php_pod --container php -- bash -c "tail -n 100 /var/log/apache2/error.log 2>/dev/null | grep -i 'ServerName' || echo 'Không có cảnh báo ServerName.'" || {
  echo "⚠️ Vẫn có cảnh báo ServerName trong log Apache hoặc không thể đọc log."
  echo "🔍 Nội dung file apache2.conf:"
  kubectl exec $php_pod --container php -- cat /etc/apache2/apache2.conf | grep ServerName
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
}

echo "✅ [16.4] Khởi động lại Apache (graceful reload) hoàn tất."
echo "✅ Đoạn 16 hoàn tất: Cấu hình Apache và xử lý lỗi module PDO hoàn tất."