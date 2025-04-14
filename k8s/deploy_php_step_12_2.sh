# 12.2. Lấy tên pod PHP và MySQL
echo "🔍 Lấy tên pod PHP và MySQL..."

# Lấy tên pod PHP
php_pod=$(kubectl get pods -l app=php -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$php_pod" ]; then
    echo "❌ Không tìm thấy pod PHP."
    echo "🔍 Danh sách pod:"
    kubectl get pods -l app=php
    exit 1
fi

# Lấy tên pod MySQL
mysql_pod=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$mysql_pod" ]; then
    echo "❌ Không tìm thấy pod MySQL."
    echo "🔍 Danh sách pod:"
    kubectl get pods -l app=mysql
    exit 1
fi

# Lưu tên pod vào file tạm
echo "$php_pod" > /tmp/php_pod_name.txt
echo "$mysql_pod" > /tmp/mysql_pod_name.txt

# Kiểm tra trạng thái pod
echo "🔍 Kiểm tra trạng thái pod PHP ($php_pod)..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
    echo "❌ Pod PHP ($php_pod) không sẵn sàng."
    echo "🔍 Trạng thái pod: $php_status"
    echo "🔍 Trạng thái ready: $php_ready"
    echo "🔍 Chi tiết pod:"
    kubectl describe pod $php_pod
    echo "🔍 Log của pod PHP:"
    kubectl logs $php_pod
    exit 1
fi

echo "🔍 Kiểm tra trạng thái pod MySQL ($mysql_pod)..."
mysql_status=$(kubectl get pod $mysql_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
mysql_ready=$(kubectl get pod $mysql_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$mysql_status" != "Running" ] || [ "$mysql_ready" != "true" ]; then
    echo "❌ Pod MySQL ($mysql_pod) không sẵn sàng."
    echo "🔍 Trạng thái pod: $mysql_status"
    echo "🔍 Trạng thái ready: $mysql_ready"
    echo "🔍 Chi tiết pod:"
    kubectl describe pod $mysql_pod
    echo "🔍 Log của pod MySQL:"
    kubectl logs $mysql_pod
    exit 1
fi

echo "✅ Tên pod PHP: $php_pod"
echo "✅ Tên pod MySQL: $mysql_pod"
echo "✅ [12.2] Lấy tên pod PHP và MySQL hoàn tất."