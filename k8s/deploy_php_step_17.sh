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

# Hàm tạo và kiểm tra Cloudflare Tunnel
create_and_check_tunnel() {
  local name=$1
  local port=$2
  local logfile=$3
  local pid_file=$4

  # Tạo Cloudflare Tunnel
  echo "🔍 Tạo Cloudflare Tunnel cho $name ($port)..."
  nohup cloudflared tunnel --url http://localhost:$port --logfile $logfile > /dev/null 2>&1 &
  TUNNEL_PID=$!
  disown $TUNNEL_PID
  echo $TUNNEL_PID > $pid_file

  # Đợi 15 giây để tunnel khởi tạo
  sleep 15

  # Lấy URL cuối cùng từ logfile
  tunnel_url=$(grep -o "https://.*\.trycloudflare\.com" $logfile | tail -n 1 || echo "")
  if [ -z "$tunnel_url" ]; then
    echo "❌ Không thể tạo Cloudflare Tunnel cho $name."
    cat $logfile
    return 1
  fi

  # Kiểm tra kết nối với thời gian chờ tăng lên
  echo "🔍 Kiểm tra kết nối đến $tunnel_url ($name)..."
  retry_count=0
  max_retries=5
  while [ $retry_count -lt $max_retries ]; do
    if curl --connect-timeout 10 --retry 2 --retry-delay 5 "$tunnel_url" >/dev/null 2>&1; then
      echo "✅ Kết nối đến $tunnel_url ($name) thành công."
      echo $tunnel_url > /tmp/${name}_tunnel_url.txt
      return 0
    fi
    echo "⚠️ Không thể truy cập $tunnel_url ($name). Thử lại lần $((retry_count + 1))/$max_retries..."
    sleep 5
    retry_count=$((retry_count + 1))
  done

  # Nếu kiểm tra thất bại, yêu cầu kiểm tra thủ công
  echo "❌ Không thể truy cập $tunnel_url ($name) sau $max_retries lần thử."
  echo "🔍 Vui lòng kiểm tra thủ công URL: $tunnel_url"
  read -p "URL có hoạt động không? (y/n): " manual_check
  if [ "$manual_check" = "y" ]; then
    echo "✅ Người dùng xác nhận URL hoạt động."
    echo $tunnel_url > /tmp/${name}_tunnel_url.txt
    return 0
  else
    echo "❌ URL không hoạt động."
    kubectl logs "$php_pod" -n default 2>/dev/null || echo "⚠️ Không thể lấy log."
    return 1
  fi
}

# Tạo và kiểm tra tunnel cho User và Admin đồng thời
create_and_check_tunnel "User" 8080 "cloudflared-User.log" "/tmp/cloudflared_pid.txt" &
USER_PID=$!

create_and_check_tunnel "Admin" 8081 "cloudflared-admin.log" "/tmp/cloudflared_admin_pid.txt" &
ADMIN_PID=$!

# Đợi cả hai tunnel hoàn thành
wait $USER_PID
USER_STATUS=$?
wait $ADMIN_PID
ADMIN_STATUS=$?

# Kiểm tra kết quả
if [ $USER_STATUS -ne 0 ]; then
  echo "❌ Tạo tunnel cho User thất bại."
  exit 1
fi

if [ $ADMIN_STATUS -ne 0 ]; then
  echo "❌ Tạo tunnel cho Admin thất bại."
  exit 1
fi

# Lấy URL từ file tạm
User_tunnel_url=$(cat /tmp/User_tunnel_url.txt)
tunnel_admin_url=$(cat /tmp/Admin_tunnel_url.txt)

echo "✅ [17] Đã tạo tunnel thành công."
echo "🔗 Truy cập User tại: $User_tunnel_url"
echo "🔗 Truy cập Admin tại: $tunnel_admin_url"

# Lưu PID port-forward
echo $PORT_FORWARD_PID > /tmp/port_forward_pid.txt
echo $PORT_FORWARD_ADMIN_PID > /tmp/port_forward_admin_pid.txt