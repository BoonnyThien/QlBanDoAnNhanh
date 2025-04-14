#!/bin/bash

# 16.3. Kiểm tra module PDO
echo "🚀 [16.3] Kiểm tra module PDO..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi xử lý
echo "🔍 Kiểm tra trạng thái pod PHP trước khi kiểm tra module PDO..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng để kiểm tra module PDO."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

# Kiểm tra các file .ini trong conf.d
echo "🔍 Kiểm tra các file .ini trong /usr/local/etc/php/conf.d..."
kubectl exec $php_pod --container php -- bash -c "ls -l /usr/local/etc/php/conf.d" || {
  echo "❌ Không thể liệt kê các file trong /usr/local/etc/php/conf.d."
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Kiểm tra xem module PDO có bị load nhiều lần không
echo "🔍 Kiểm tra module PDO..."
pdo_count=$(kubectl exec $php_pod --container php -- php -m | grep -E "^pdo$" | wc -l)
if [ "$pdo_count" -gt 1 ]; then
  echo "⚠️ Module PDO được load nhiều lần ($pdo_count lần). Xử lý..."
  # Xóa các file .ini dư thừa
  kubectl exec $php_pod --container php -- bash -c "grep -l 'extension=pdo.so' /usr/local/etc/php/conf.d/*.ini | sort | uniq | tail -n +2 | xargs -I {} rm -f {}" || {
    echo "❌ Không thể xóa các file .ini dư thừa."
    echo "🔍 Kiểm tra lại các file .ini:"
    kubectl exec $php_pod --container php -- ls -l /usr/local/etc/php/conf.d
    echo "🔍 Log của pod PHP:"
    kubectl logs $php_pod
    exit 1
  }
  # Ghi lại file duy nhất
  kubectl exec $php_pod --container php -- bash -c "echo 'extension=pdo.so' > /usr/local/etc/php/conf.d/docker-php-ext-pdo.ini" || {
    echo "❌ Không thể ghi lại file docker-php-ext-pdo.ini."
    echo "🔍 Kiểm tra lại các file .ini:"
    kubectl exec $php_pod --container php -- ls -l /usr/local/etc/php/conf.d
    echo "🔍 Log của pod PHP:"
    kubectl logs $php_pod
    exit 1
  }
else
  echo "✅ Module PDO chỉ được load một lần."
fi

# Kiểm tra xem module PDO và PDO-MySQL có được load không
echo "🔍 Kiểm tra lại module PDO và PDO-MySQL..."
if kubectl exec $php_pod --container php -- php -m | grep -q "pdo" && kubectl exec $php_pod --container php -- php -m | grep -q "pdo_mysql"; then
  echo "✅ Module PDO và PDO-MySQL đã được tải."
else
  echo "❌ Module PDO hoặc PDO-MySQL không được tải."
  echo "🔍 Kiểm tra danh sách module PHP:"
  kubectl exec $php_pod --container php -- php -m
  echo "🔍 Kiểm tra file .ini trong conf.d:"
  kubectl exec $php_pod --container php -- ls -l /usr/local/etc/php/conf.d
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

echo "✅ [16.3] Kiểm tra module PDO hoàn tất."