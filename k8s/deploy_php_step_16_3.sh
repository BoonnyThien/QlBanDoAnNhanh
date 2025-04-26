# Step 16.3: Kiểm tra module PDO
echo "🚀 [16.3] Kiểm tra module PDO..."

# Kiểm tra pod PHP (User)
echo "🔍 Kiểm tra trạng thái pod PHP (User) trước khi kiểm tra module PDO..."
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP (User) ($php_pod) không sẵn sàng để kiểm tra module PDO."
  exit 1
fi

echo "🔍 Kiểm tra các file .ini trong /usr/local/etc/php/conf.d cho PHP (User)..."
kubectl exec $php_pod --container php-app -- ls /usr/local/etc/php/conf.d || {
  echo "❌ Không thể liệt kê các file trong /usr/local/etc/php/conf.d cho PHP (User)."
  echo "🔍 Log của pod PHP (User):"
  kubectl logs $php_pod --container php-app
  exit 1
}

# Kiểm tra pod PHP Admin
echo "🔍 Kiểm tra trạng thái pod PHP Admin trước khi kiểm tra module PDO..."
if [ "$php_admin_status" != "Running" ] || [ "$php_admin_ready" != "true" ]; then
  echo "❌ Pod PHP Admin ($php_admin_pod) không sẵn sàng để kiểm tra module PDO."
  exit 1
fi

echo "🔍 Kiểm tra các file .ini trong /usr/local/etc/php/conf.d cho PHP Admin..."
kubectl exec $php_admin_pod --container php-admin -- ls /usr/local/etc/php/conf.d || {
  echo "❌ Không thể liệt kê các file trong /usr/local/etc/php/conf.d cho PHP Admin."
  echo "🔍 Log của pod PHP Admin:"
  kubectl logs $php_admin_pod --container php-admin
  exit 1
}