#!/bin/bash

# 12.3. Cài đặt các công cụ mạng và kiểm tra kết nối
echo "🚀 [12.3] Cài đặt các công cụ mạng và kiểm tra kết nối..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Cài đặt các gói cần thiết để kiểm tra kết nối mạng
echo "🔍 Cài đặt các công cụ kiểm tra mạng (iputils-ping, iproute2)..."
kubectl exec $php_pod --container php -- bash -c "sudo apt-get update 2>&1" || {
  echo "❌ Không thể cập nhật gói apt-get."
  echo "🔍 Kiểm tra DNS:"
  kubectl exec $php_pod --container php -- cat /etc/resolv.conf
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

kubectl exec $php_pod --container php -- bash -c "sudo apt-get install -y iputils-ping iproute2 2>&1" || {
  echo "❌ Không thể cài đặt iputils-ping và iproute2."
  echo "🔍 Kiểm tra danh sách gói đã cài đặt:"
  kubectl exec $php_pod --container php -- dpkg -l | grep -E "iputils-ping|iproute2"
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Kiểm tra kết nối mạng để đảm bảo container có thể tải gói
echo "🔍 Kiểm tra kết nối mạng trong container..."
kubectl exec $php_pod --container php -- ping -c 3 8.8.8.8 || {
  echo "⚠️ Container không có kết nối mạng."
  echo "🔍 Kiểm tra DNS:"
  kubectl exec $php_pod --container php -- cat /etc/resolv.conf
  echo "🔍 Kiểm tra routing:"
  kubectl exec $php_pod --container php -- ip route
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

echo "✅ [12.3] Cài đặt các công cụ mạng và kiểm tra kết nối hoàn tất."