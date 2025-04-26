#!/bin/bash

# 12.6. Khởi động lại pod PHP để áp dụng cấu hình (cả php-app và php-admin)
echo "🚀 [12.6] Khởi động lại pod PHP..."

# Khởi động lại pod PHP (User)
echo "🔍 Khởi động lại pod PHP (User)..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP (User). Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi khởi động lại
echo "🔍 Kiểm tra trạng thái pod PHP (User) trước khi khởi động lại..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP (User) ($php_pod) không sẵn sàng để khởi động lại."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP (User):"
  kubectl logs $php_pod --container php-app
  exit 1
fi

# Kiểm tra lại cấu hình ServerName
echo "🔍 Kiểm tra cấu hình ServerName trong apache2.conf cho PHP (User)..."
kubectl exec $php_pod --container php-app -- bash -c "grep 'ServerName' /etc/apache2/apache2.conf" || {
  echo "⚠️ Không tìm thấy cấu hình ServerName trong /etc/apache2/apache2.conf. Thêm lại cấu hình..."
  kubectl exec $php_pod --container php-app -- bash -c "echo 'ServerName localhost' >> /etc/apache2/apache2.conf" || {
    echo "❌ Không thể thêm ServerName vào apache2.conf cho PHP (User)."
    echo "🔍 Log của pod PHP (User):"
    kubectl logs $php_pod --container php-app
    exit 1
  }
}

# Khởi động lại pod để áp dụng thay đổi
echo "🔍 Khởi động lại pod PHP (User) để áp dụng cấu hình..."
kubectl delete pod $php_pod --force --grace-period=0
echo "🔍 Đợi pod PHP (User) khởi động lại..."
kubectl rollout status deployment/php-deployment --timeout=120s || {
  echo "❌ Pod PHP (User) không sẵn sàng sau khi khởi động lại."
  echo "🔍 Chi tiết deployment:"
  kubectl describe deployment php-deployment
  echo "🔍 Log của pod PHP (User):"
  kubectl logs -l app=php-app
  exit 1
}

# Lấy tên pod mới sau khi khởi động lại
echo "🔍 Lấy tên pod PHP (User) mới..."
php_pod=$(kubectl get pods -l app=php-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy pod PHP (User) sau khi khởi động lại."
  echo "🔍 Danh sách pod:"
  kubectl get pods -l app=php-app
  exit 1
fi

# Kiểm tra trạng thái pod sau khi khởi động lại
echo "🔍 Kiểm tra trạng thái pod PHP (User) sau khi khởi động lại..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP (User) ($php_pod) không sẵn sàng sau khi khởi động lại."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP (User):"
  kubectl logs $php_pod --container php-app
  exit 1
fi

# Cập nhật tên pod mới vào file tạm
echo "$php_pod" > /tmp/php_pod_name.txt

# Khởi động lại pod PHP Admin
echo "🔍 Khởi động lại pod PHP Admin..."

# Đọc tên pod từ file tạm
php_admin_pod=$(cat /tmp/php_admin_pod_name.txt)
if [ -z "$php_admin_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP Admin. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi khởi động lại
echo "🔍 Kiểm tra trạng thái pod PHP Admin trước khi khởi động lại..."
php_admin_status=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_admin_ready=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_admin_status" != "Running" ] || [ "$php_admin_ready" != "true" ]; then
  echo "❌ Pod PHP Admin ($php_admin_pod) không sẵn sàng để khởi động lại."
  echo "🔍 Trạng thái pod: $php_admin_status"
  echo "🔍 Trạng thái ready: $php_admin_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_admin_pod
  echo "🔍 Log của pod PHP Admin:"
  kubectl logs $php_admin_pod --container php-admin
  exit 1
fi

# Kiểm tra lại cấu hình ServerName
echo "🔍 Kiểm tra cấu hình ServerName trong apache2.conf cho PHP Admin..."
kubectl exec $php_admin_pod --container php-admin -- bash -c "grep 'ServerName' /etc/apache2/apache2.conf" || {
  echo "⚠️ Không tìm thấy cấu hình ServerName trong /etc/apache2/apache2.conf. Thêm lại cấu hình..."
  kubectl exec $php_admin_pod --container php-admin -- bash -c "echo 'ServerName localhost' >> /etc/apache2/apache2.conf" || {
    echo "❌ Không thể thêm ServerName vào apache2.conf cho PHP Admin."
    echo "🔍 Log của pod PHP Admin:"
    kubectl logs $php_admin_pod --container php-admin
    exit 1
  }
}

# Khởi động lại pod để áp dụng thay đổi
echo "🔍 Khởi động lại pod PHP Admin để áp dụng cấu hình..."
kubectl delete pod $php_admin_pod --force --grace-period=0
echo "🔍 Đợi pod PHP Admin khởi động lại..."
kubectl rollout status deployment/php-admin-deployment --timeout=120s || {
  echo "❌ Pod PHP Admin không sẵn sàng sau khi khởi động lại."
  echo "🔍 Chi tiết deployment:"
  kubectl describe deployment php-admin-deployment
  echo "🔍 Log của pod PHP Admin:"
  kubectl logs -l app=php-admin
  exit 1
}

# Lấy tên pod mới sau khi khởi động lại
echo "🔍 Lấy tên pod PHP Admin mới..."
php_admin_pod=$(kubectl get pods -l app=php-admin -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$php_admin_pod" ]; then
  echo "❌ Không tìm thấy pod PHP Admin sau khi khởi động lại."
  echo "🔍 Danh sách pod:"
  kubectl get pods -l app=php-admin
  exit 1
fi

# Kiểm tra trạng thái pod sau khi khởi động lại
echo "🔍 Kiểm tra trạng thái pod PHP Admin sau khi khởi động lại..."
php_admin_status=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_admin_ready=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_admin_status" != "Running" ] || [ "$php_admin_ready" != "true" ]; then
  echo "❌ Pod PHP Admin ($php_admin_pod) không sẵn sàng sau khi khởi động lại."
  echo "🔍 Trạng thái pod: $php_admin_status"
  echo "🔍 Trạng thái ready: $php_admin_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_admin_pod
  echo "🔍 Log của pod PHP Admin:"
  kubectl logs $php_admin_pod --container php-admin
  exit 1
fi

# Cập nhật tên pod mới vào file tạm
echo "$php_admin_pod" > /tmp/php_admin_pod_name.txt

echo "✅ [12.6] Khởi động lại pod PHP hoàn tất."
echo "✅ Đoạn 12 hoàn tất: Deployment PHP đã được tạo và cấu hình thành công."