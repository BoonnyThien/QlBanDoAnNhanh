#!/bin/bash

set -e

echo "🚀 [17] Tạo tunnel để truy cập dịch vụ PHP qua Cloudflare..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt 2>/dev/null || echo "")
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod
echo "🔍 Kiểm tra trạng thái pod PHP..."
php_status=$(kubectl get pod "$php_pod" -o jsonpath='{.status.phase}' -n default 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod "$php_pod" -o jsonpath='{.status.containerStatuses[0].ready}' -n default 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng."
  kubectl describe pod "$php_pod" -n default
  kubectl logs "$php_pod" -n default 2>/dev/null || echo "⚠️ Không thể lấy log."
  exit 1
fi

# Kiểm tra dịch vụ php-service
echo "🔍 Kiểm tra dịch vụ php-service..."
kubectl get service php-service -n default >/dev/null 2>&1 || {
  echo "❌ Dịch vụ php-service không tồn tại."
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

# Chuyển tiếp Service php-service đến localhost
echo "🔍 Chuyển tiếp Service php-service đến localhost:8080..."
nohup kubectl port-forward service/php-service 8080:80 > port-forward.log 2>&1 &
PORT_FORWARD_PID=$!
disown $PORT_FORWARD_PID
sleep 5

# Kiểm tra port-forward
if ! ss -tuln | grep 8080 >/dev/null; then
  echo "❌ Không thể chuyển tiếp port 8080."
  cat port-forward.log
  exit 1
fi

# Tạo Cloudflare Tunnel
echo "🔍 Tạo Cloudflare Tunnel..."
nohup cloudflared tunnel --url http://localhost:8080 --logfile cloudflared.log > /dev/null 2>&1 &
TUNNEL_PID=$!
disown $TUNNEL_PID
sleep 10

# Lấy URL từ Cloudflare
tunnel_url=$(grep -o "https://.*\.trycloudflare\.com" cloudflared.log || echo "")
if [ -z "$tunnel_url" ]; then
  echo "❌ Không thể tạo Cloudflare Tunnel."
  cat cloudflared.log
  exit 1
fi

# Kiểm tra kết nối
echo "🔍 Kiểm tra kết nối đến $tunnel_url..."
retry_count=0
max_retries=3
while [ $retry_count -lt $max_retries ]; do
  if curl --connect-timeout 5 "$tunnel_url" >/dev/null 2>&1; then
    echo "✅ Kết nối đến $tunnel_url thành công."
    break
  fi
  echo "⚠️ Không thể truy cập $tunnel_url. Thử lại lần $((retry_count + 1))/$max_retries..."
  sleep 5
  retry_count=$((retry_count + 1))
done

if [ $retry_count -eq $max_retries ]; then
  echo "❌ Không thể truy cập $tunnel_url sau $max_retries lần thử."
  kubectl logs "$php_pod" -n default 2>/dev/null || echo "⚠️ Không thể lấy log."
  exit 1
fi

echo "✅ [17] Đã tạo tunnel thành công."
echo "🔗 Truy cập tại: $tunnel_url"

# Lưu PID để quản lý sau này
echo $PORT_FORWARD_PID > /tmp/port_forward_pid.txt
echo $TUNNEL_PID > /tmp/cloudflared_pid.txt