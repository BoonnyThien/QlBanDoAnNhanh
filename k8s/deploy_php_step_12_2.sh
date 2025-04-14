#!/bin/bash

# 12.2. Cấu hình thư mục và copy file php.ini
echo "🚀 [12.2] Cấu hình thư mục và copy file php.ini..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra quyền của thư mục /usr/local/etc/php
echo "🔍 Kiểm tra quyền của thư mục /usr/local/etc/php..."
kubectl exec $php_pod --container php -- ls -ld /usr/local/etc/php || {
  echo "❌ Không thể kiểm tra quyền của thư mục /usr/local/etc/php."
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Kiểm tra xem /usr/local/etc/php có phải read-only filesystem không
echo "🔍 Kiểm tra xem /usr/local/etc/php có phải read-only filesystem không..."
kubectl exec $php_pod --container php -- bash -c "mount | grep /usr/local/etc/php | grep 'ro,' || echo 'Không phải read-only filesystem'" || {
  echo "⚠️ /usr/local/etc/php là read-only filesystem hoặc có lỗi khác."
  echo "🔍 Kiểm tra mount points:"
  kubectl exec $php_pod --container php -- mount | grep /usr/local/etc
  echo "🔍 Kiểm tra quyền của thư mục /usr/local/etc/php:"
  kubectl exec $php_pod --container php -- ls -ld /usr/local/etc/php
  echo "🔍 Kiểm tra quyền của thư mục /usr/local/etc:"
  kubectl exec $php_pod --container php -- ls -ld /usr/local/etc
  echo "🔍 Kiểm tra quyền của thư mục /usr/local:"
  kubectl exec $php_pod --container php -- ls -ld /usr/local
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Kiểm tra xem sudo đã được cài đặt chưa
echo "🔍 Kiểm tra xem sudo đã được cài đặt chưa..."
kubectl exec $php_pod --container php -- which sudo >/dev/null 2>&1 || {
  echo "🔍 Cài đặt sudo trong container..."
  kubectl exec $php_pod --container php -- bash -c "apt-get update && apt-get install -y sudo 2>&1" || {
    echo "❌ Không thể cài đặt sudo trong container."
    echo "🔍 Log của pod PHP:"
    kubectl logs $php_pod
    exit 1
  }
}

# Tạo thư mục conf.d với sudo
echo "🔍 Tạo thư mục /usr/local/etc/php/conf.d..."
kubectl exec $php_pod --container php -- bash -c "sudo mkdir -p /usr/local/etc/php/conf.d" || {
  echo "❌ Không thể tạo thư mục /usr/local/etc/php/conf.d."
  echo "🔍 Kiểm tra quyền của thư mục cha /usr/local/etc/php:"
  kubectl exec $php_pod --container php -- ls -ld /usr/local/etc/php
  echo "🔍 Kiểm tra quyền của thư mục /usr/local/etc:"
  kubectl exec $php_pod --container php -- ls -ld /usr/local/etc
  echo "🔍 Kiểm tra quyền của thư mục /usr/local:"
  kubectl exec $php_pod --container php -- ls -ld /usr/local
  echo "🔍 Kiểm tra mount points:"
  kubectl exec $php_pod --container php -- mount | grep /usr/local/etc
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Copy file php.ini từ /tmp/php-config vào /usr/local/etc/php/conf.d
echo "🔍 Copy file php.ini từ ConfigMap vào /usr/local/etc/php/conf.d..."
kubectl exec $php_pod --container php -- bash -c "sudo cp /tmp/php-config/php.ini /usr/local/etc/php/conf.d/php.ini" || {
  echo "❌ Không thể copy file php.ini từ ConfigMap."
  echo "🔍 Kiểm tra file trong /tmp/php-config:"
  kubectl exec $php_pod --container php -- ls -l /tmp/php-config
  echo "🔍 Kiểm tra nội dung thư mục /usr/local/etc/php/conf.d:"
  kubectl exec $php_pod --container php -- ls -l /usr/local/etc/php/conf.d
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Đảm bảo quyền truy cập cho thư mục conf.d
echo "🔍 Đảm bảo quyền truy cập cho thư mục /usr/local/etc/php/conf.d..."
kubectl exec $php_pod --container php -- bash -c "sudo chmod 755 /usr/local/etc/php/conf.d" || {
  echo "❌ Không thể thay đổi quyền thư mục /usr/local/etc/php/conf.d."
  echo "🔍 Kiểm tra quyền của thư mục /usr/local/etc/php/conf.d:"
  kubectl exec $php_pod --container php -- ls -ld /usr/local/etc/php/conf.d
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

echo "✅ [12.2] Cấu hình thư mục và copy file php.ini hoàn tất."