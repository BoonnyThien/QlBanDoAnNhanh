#!/bin/bash

set -e

echo "🚀 [17] Tạo tunnel để truy cập dịch vụ PHP (User và Admin) qua Cloudflare..."

# Đọc tên pod từ file tạm (User)
php_pod=$(cat /tmp/php_pod_name.txt 2>/dev/null || echo "")
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP User. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Đọc tên pod từ file tạm (Admin)
php_admin_pod=$(cat /tmp/php_admin_pod_name.txt 2>/dev/null || echo "")
if [ -z "$php_admin_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP Admin. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod PHP User
echo "🔍 Kiểm tra trạng thái pod PHP User..."
php_status=$(kubectl get pod "$php_pod" -o jsonpath='{.status.phase}' -n default 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod "$php_pod" -o jsonpath='{.status.containerStatuses[0].ready}' -n default 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP User ($php_pod) không sẵn sàng."
  kubectl describe pod "$php_pod" -n default
  kubectl logs "$php_pod" -n default 2>/dev/null || echo "⚠️ Không thể lấy log."
  exit 1
fi

# Kiểm tra trạng thái pod PHP Admin
echo "🔍 Kiểm tra trạng thái pod PHP Admin..."
php_admin_status=$(kubectl get pod "$php_admin_pod" -o jsonpath='{.status.phase}' -n default 2>/dev/null || echo "NotRunning")
php_admin_ready=$(kubectl get pod "$php_admin_pod" -o jsonpath='{.status.containerStatuses[0].ready}' -n default 2>/dev/null || echo "false")
if [ "$php_admin_status" != "Running" ] || [ "$php_admin_ready" != "true" ]; then
  echo "❌ Pod PHP Admin ($php_admin_pod) không sẵn sàng."
  kubectl describe pod "$php_admin_pod" -n default
  kubectl logs "$php_admin_pod" -n default 2>/dev/null || echo "⚠️ Không thể lấy log."
  exit 1
fi

# Kiểm tra dịch vụ php-app-service (User)
echo "🔍 Kiểm tra dịch vụ php-app-service..."
kubectl get service php-app-service -n default >/dev/null 2>&1 || {
  echo "❌ Dịch vụ php-app-service không tồn tại."
  exit 1
}

# Kiểm tra dịch vụ php-admin-service (Admin)
echo "🔍 Kiểm tra dịch vụ php-admin-service..."
kubectl get service php-admin-service -n default >/dev/null 2>&1 || {
  echo "❌ Dịch vụ php-admin-service không tồn tại."
  exit 1
}

# Kiểm tra và cài đặt cloudflared nếu chưa có
if ! command -v cloudflared >/dev/null 2>&1; then
  echo "🔍 Cài đặt cloudflared..."
  wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
  chmod +x cloudflared
  sudo mv cloudflared /usr/local/bin/
fi

# Dừng các tunnel cũ (nếu có)
pkill -f "cloudflared tunnel" 2>/dev/null || true
pkill -f "kubectl port-forward" 2>/dev/null || true

# Chuyển tiếp Service php-app-service đến localhost:8080 (User)
echo "🔍 Chuyển tiếp Service php-app-service đến localhost:8080..."
nohup kubectl port-forward service/php-app-service 8080:80 -n default > port-forward-User.log 2>&1 &
PORT_FORWARD_PID=$!
disown $PORT_FORWARD_PID
sleep 5

# Kiểm tra port-forward cho 8080
if ! ss -tuln | grep 8080 >/dev/null; then
  echo "❌ Không thể chuyển tiếp port 8080 cho User."
  cat port-forward-User.log
  exit 1
fi

# Chuyển tiếp Service php-admin-service đến localhost:8081 (Admin)
echo "🔍 Chuyển tiếp Service php-admin-service đến localhost:8081..."
nohup kubectl port-forward service/php-admin-service 8081:80 -n default > port-forward-admin.log 2>&1 &
PORT_FORWARD_ADMIN_PID=$!
disown $PORT_FORWARD_ADMIN_PID
sleep 5

# Kiểm tra port-forward cho 8081
if ! ss -tuln | grep 8081 >/dev/null; then
  echo "❌ Không thể chuyển tiếp port 8081 cho Admin."
  cat port-forward-admin.log
  exit 1
fi

# Tạo Cloudflare Tunnel cho User (8080)
echo "🔍 Tạo Cloudflare Tunnel cho User (8080)..."
nohup cloudflared tunnel --url http://localhost:8080 --logfile cloudflared-User.log > /dev/null 2>&1 &
TUNNEL_PID=$!
disown $TUNNEL_PID
sleep 10

# Lấy URL từ Cloudflare cho User
tunnel_url=$(grep -o "https://.*\.trycloudflare\.com" cloudflared-User.log || echo "")
if [ -z "$tunnel_url" ]; then
  echo "❌ Không thể tạo Cloudflare Tunnel cho User."
  cat cloudflared-User.log
  exit 1
fi

# Kiểm tra kết nối cho User
echo "🔍 Kiểm tra kết nối đến $tunnel_url (User)..."
retry_count=0
max_retries=3
while [ $retry_count -lt $max_retries ]; do
  if curl --connect-timeout 5 "$tunnel_url" >/dev/null 2>&1; then
    echo "✅ Kết nối đến $tunnel_url (User) thành công."
    break
  fi
  echo "⚠️ Không thể truy cập $tunnel_url (User). Thử lại lần $((retry_count + 1))/$max_retries..."
  sleep 5
  retry_count=$((retry_count + 1))
done

if [ $retry_count -eq $max_retries ]; then
  echo "❌ Không thể truy cập $tunnel_url (User) sau $max_retries lần thử."
  kubectl logs "$php_pod" -n default 2>/dev/null || echo "⚠️ Không thể lấy log."
  exit 1
fi

# Lưu URL của User
User_tunnel_url=$tunnel_url

# Tạo Cloudflare Tunnel cho Admin (8081)
echo "🔍 Tạo Cloudflare Tunnel cho Admin (8081)..."
nohup cloudflared tunnel --url http://localhost:8081 --logfile cloudflared-admin.log > /dev/null 2>&1 &
TUNNEL_ADMIN_PID=$!
disown $TUNNEL_ADMIN_PID
sleep 10

# Lấy URL từ Cloudflare cho Admin
tunnel_admin_url=$(grep -o "https://.*\.trycloudflare\.com" cloudflared-admin.log || echo "")
if [ -z "$tunnel_admin_url" ]; then
  echo "❌ Không thể tạo Cloudflare Tunnel cho Admin."
  cat cloudflared-admin.log
  exit 1
fi

# Kiểm tra kết nối cho Admin
echo "🔍 Kiểm tra kết nối đến $tunnel_admin_url (Admin)..."
retry_count=0
max_retries=3
while [ $retry_count -lt $max_retries ]; do
  if curl --connect-timeout 5 "$tunnel_admin_url" >/dev/null 2>&1; then
    echo "✅ Kết nối đến $tunnel_admin_url (Admin) thành công."
    break
  fi
  echo "⚠️ Không thể truy cập $tunnel_admin_url (Admin). Thử lại lần $((retry_count + 1))/$max_retries..."
  sleep 5
  retry_count=$((retry_count + 1))
done

if [ $retry_count -eq $max_retries ]; then
  echo "❌ Không thể truy cập $tunnel_admin_url (Admin) sau $max_retries lần thử."
  kubectl logs "$php_admin_pod" -n default 2>/dev/null || echo "⚠️ Không thể lấy log."
  exit 1
fi

echo "✅ [17] Đã tạo tunnel thành công."
echo "🔗 Truy cập User tại: $User_tunnel_url"
echo "🔗 Truy cập Admin tại: $tunnel_admin_url"

# Lưu PID để quản lý sau này
echo $PORT_FORWARD_PID > /tmp/port_forward_pid.txt
echo $PORT_FORWARD_ADMIN_PID > /tmp/port_forward_admin_pid.txt
echo $TUNNEL_PID > /tmp/cloudflared_pid.txt
echo $TUNNEL_ADMIN_PID > /tmp/cloudflared_admin_pid.txt