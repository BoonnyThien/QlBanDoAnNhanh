# Step 16.2: Kiểm tra module mod_rewrite
echo "🚀 [16.2] Kiểm tra module mod_rewrite..."

# Kiểm tra pod PHP (User)
echo "🔍 Kiểm tra trạng thái pod PHP (User) trước khi kiểm tra module mod_rewrite..."
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP (User) ($php_pod) không sẵn sàng để kiểm tra module mod_rewrite."
  exit 1
fi

echo "🔍 Kiểm tra trạng thái module mod_rewrite cho PHP (User)..."
if kubectl exec $php_pod --container php-app -- apachectl -M | grep -q rewrite_module; then
  echo "✅ Module mod_rewrite đã được bật cho PHP (User)."
else
  echo "🔍 Module mod_rewrite chưa được bật. Tiến hành bật..."
  kubectl exec $php_pod --container php-app -- a2enmod rewrite || {
    echo "❌ Không thể bật module mod_rewrite cho PHP (User)."
    echo "🔍 Log của pod PHP (User):"
    kubectl logs $php_pod --container php-app
    exit 1
  }
fi

# Kiểm tra pod PHP Admin
echo "🔍 Kiểm tra trạng thái pod PHP Admin trước khi kiểm tra module mod_rewrite..."
if [ "$php_admin_status" != "Running" ] || [ "$php_admin_ready" != "true" ]; then
  echo "❌ Pod PHP Admin ($php_admin_pod) không sẵn sàng để kiểm tra module mod_rewrite."
  exit 1
fi

echo "🔍 Kiểm tra trạng thái module mod_rewrite cho PHP Admin..."
if kubectl exec $php_admin_pod --container php-admin -- apachectl -M | grep -q rewrite_module; then
  echo "✅ Module mod_rewrite đã được bật cho PHP Admin."
else
  echo "🔍 Module mod_rewrite chưa được bật. Tiến hành bật..."
  kubectl exec $php_admin_pod --container php-admin -- a2enmod rewrite || {
    echo "❌ Không thể bật module mod_rewrite cho PHP Admin."
    echo "🔍 Log của pod PHP Admin:"
    kubectl logs $php_admin_pod --container php-admin
    exit 1
  }
fi
