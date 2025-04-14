#!/bin/bash

# 12.6. Khởi động lại Apache
echo "🚀 [12.6] Khởi động lại Apache..."

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

# Kiểm tra lại cấu hình ServerName
echo "🔍 Kiểm tra cấu hình ServerName trong apache2.conf..."
kubectl exec $php_pod --container php -- bash -c "grep 'ServerName' /etc/apache2/apache2.conf" || {
  echo "⚠️ Không tìm thấy cấu hình ServerName trong /etc/apache2/apache2.conf. Thêm lại cấu hình..."
  kubectl exec $php_pod --container php -- bash -c "echo 'ServerName localhost' | sudo tee -a /etc/apache2/apache2.conf" || {
    echo "❌ Không thể thêm ServerName vào apache2.conf."
    echo "🔍 Log của pod PHP:"
    kubectl logs $php_pod
    exit 1
  }
}

# Đợi một chút để đảm bảo container ổn định
echo "🔍 Đợi 5 giây để container ổn định trước khi khởi động lại Apache..."
sleep 5

# Khởi động lại Apache bằng apache2ctl graceful thay vì service apache2 restart
echo "🔍 Khởi động lại Apache (graceful reload) sau khi cấu hình..."
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

echo "✅ [12.6] Khởi động lại Apache hoàn tất."
echo "✅ Đoạn 12 hoàn tất: Deployment PHP đã được tạo và cấu hình thành công."