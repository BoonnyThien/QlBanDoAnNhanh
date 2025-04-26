# Step 16.1: Cấu hình ServerName cho Apache
echo "🚀 [16.1] Cấu hình ServerName cho Apache..."

# Kiểm tra pod PHP (User)
echo "🔍 Kiểm tra trạng thái pod PHP (User) trước khi cấu hình ServerName..."
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP (User). Vui lòng chạy bước 12.1 trước."
  exit 1
fi

php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP (User) ($php_pod) không sẵn sàng để cấu hình ServerName."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP (User):"
  kubectl logs $php_pod --container php-app
  exit 1
fi

echo "🔍 Kiểm tra cấu hình ServerName trong apache2.conf cho PHP (User)..."
kubectl exec $php_pod --container php-app -- bash -c "grep 'ServerName' /etc/apache2/apache2.conf" || {
  echo "⚠️ Không tìm thấy cấu hình ServerName trong /etc/apache2/apache2.conf. Thêm cấu hình..."
  kubectl exec $php_pod --container php-app -- bash -c "echo 'ServerName localhost' >> /etc/apache2/apache2.conf" || {
    echo "❌ Không thể thêm ServerName vào apache2.conf cho PHP (User)."
    echo "🔍 Log của pod PHP (User):"
    kubectl logs $php_pod --container php-app
    exit 1
  }
}

# Kiểm tra pod PHP Admin
echo "🔍 Kiểm tra trạng thái pod PHP Admin trước khi cấu hình ServerName..."
php_admin_pod=$(cat /tmp/php_admin_pod_name.txt)
if [ -z "$php_admin_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP Admin. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

php_admin_status=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_admin_ready=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_admin_status" != "Running" ] || [ "$php_admin_ready" != "true" ]; then
  echo "❌ Pod PHP Admin ($php_admin_pod) không sẵn sàng để cấu hình ServerName."
  echo "🔍 Trạng thái pod: $php_admin_status"
  echo "🔍 Trạng thái ready: $php_admin_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_admin_pod
  echo "🔍 Log của pod PHP Admin:"
  kubectl logs $php_admin_pod --container php-admin
  exit 1
fi

echo "🔍 Kiểm tra cấu hình ServerName trong apache2.conf cho PHP Admin..."
kubectl exec $php_admin_pod --container php-admin -- bash -c "grep 'ServerName' /etc/apache2/apache2.conf" || {
  echo "⚠️ Không tìm thấy cấu hình ServerName trong /etc/apache2/apache2.conf. Thêm cấu hình..."
  kubectl exec $php_admin_pod --container php-admin -- bash -c "echo 'ServerName localhost' >> /etc/apache2/apache2.conf" || {
    echo "❌ Không thể thêm ServerName vào apache2.conf cho PHP Admin."
    echo "🔍 Log của pod PHP Admin:"
    kubectl logs $php_admin_pod --container php-admin
    exit 1
  }
}


