#!/bin/bash

# 12.4. Cài đặt gói phụ thuộc và extension PHP
echo "🚀 [12.4] Cài đặt gói phụ thuộc và extension PHP..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Cài đặt các gói phụ thuộc cần thiết cho việc biên dịch extension
echo "🔍 Cài đặt các gói build tools và phụ thuộc..."
kubectl exec $php_pod --container php -- bash -c "sudo apt-get install -y build-essential gcc make libpq-dev default-libmysqlclient-dev 2>&1" || {
  echo "❌ Không thể cài đặt các gói phụ thuộc."
  echo "🔍 Kiểm tra danh sách gói đã cài đặt:"
  kubectl exec $php_pod --container php -- dpkg -l | grep -E "build-essential|gcc|make|libpq-dev|default-libmysqlclient-dev"
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Tìm thư mục extension động
echo "🔍 Tìm thư mục extension động..."
extension_dir=$(kubectl exec $php_pod --container php -- php -i | grep '^extension_dir' | awk '{print $3}' | head -n 1)
if [ -z "$extension_dir" ]; then
  echo "❌ Không thể tìm thấy thư mục extension."
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi
echo "Thư mục extension: $extension_dir"

# Kiểm tra xem extension đã được cài đặt chưa trước khi cài đặt lại
echo "🔍 Kiểm tra xem extension đã được cài đặt chưa..."
extension_installed=false
kubectl exec $php_pod --container php -- ls "$extension_dir/pdo.so" >/dev/null 2>&1 && kubectl exec $php_pod --container php -- ls "$extension_dir/pdo_mysql.so" >/dev/null 2>&1 && {
  echo "✅ Extension PDO và PDO-MySQL đã được cài đặt sẵn."
  extension_installed=true
}

# Cài đặt extension PHP (pdo, pdo_mysql) nếu chưa được cài đặt
if [ "$extension_installed" != "true" ]; then
  echo "🔍 Cài đặt extension PHP (pdo, pdo_mysql) mà không tự động kích hoạt..."
  kubectl exec $php_pod --container php -- bash -c "sudo sh -c 'docker-php-ext-install pdo pdo_mysql 2>&1 && rm -f /usr/local/etc/php/conf.d/docker-php-ext-*.ini'" || {
    echo "⚠️ Lệnh docker-php-ext-install trả về mã lỗi, kiểm tra lại xem extension đã được cài đặt chưa..."
    kubectl exec $php_pod --container php -- ls "$extension_dir/pdo.so" >/dev/null 2>&1 && kubectl exec $php_pod --container php -- ls "$extension_dir/pdo_mysql.so" >/dev/null 2>&1 || {
      echo "❌ Không thể cài đặt extension PHP."
      echo "🔍 Kiểm tra thư mục extension:"
      kubectl exec $php_pod --container php -- ls -l "$extension_dir" 2>/dev/null || echo "Thư mục extension không tồn tại"
      echo "🔍 Kiểm tra file .ini trong conf.d:"
      kubectl exec $php_pod --container php -- ls -l /usr/local/etc/php/conf.d
      echo "🔍 Log của pod PHP:"
      kubectl logs $php_pod
      exit 1
    }
    echo "✅ Extension PDO và PDO-MySQL đã được cài đặt bất chấp mã lỗi."
  }
else
  echo "🔍 Bỏ qua bước cài đặt vì extension đã tồn tại."
fi

# Kiểm tra lại để chắc chắn extension đã được cài đặt
echo "🔍 Kiểm tra lại xem extension đã được cài đặt chưa..."
kubectl exec $php_pod --container php -- ls "$extension_dir/pdo.so" >/dev/null 2>&1 || {
  echo "❌ Extension PDO không được cài đặt."
  echo "🔍 Kiểm tra thư mục extension:"
  kubectl exec $php_pod --container php -- ls -l "$extension_dir"
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}
kubectl exec $php_pod --container php -- ls "$extension_dir/pdo_mysql.so" >/dev/null 2>&1 || {
  echo "❌ Extension PDO-MySQL không được cài đặt."
  echo "🔍 Kiểm tra thư mục extension:"
  kubectl exec $php_pod --container php -- ls -l "$extension_dir"
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

echo "✅ [12.4] Cài đặt gói phụ thuộc và extension PHP hoàn tất."