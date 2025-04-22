# Khởi tạo biến để theo dõi xem có thay đổi cấu hình không
CONFIG_CHANGED=false

# Bước 16.4: Khởi động lại pod PHP (chỉ nếu có thay đổi)
if [ "$CONFIG_CHANGED" = "true" ]; then
  echo "🚀 [16.4] Khởi động lại pod PHP..."
  echo "🔍 Kiểm tra trạng thái pod PHP trước khi khởi động lại..."
  kubectl get pod $PHP_POD -n default
  echo "🔍 Khởi động lại pod PHP để áp dụng cấu hình..."
  kubectl delete pod $PHP_POD -n default --force
  echo "🔍 Đợi pod PHP khởi động lại..."
  kubectl wait --for=condition=Ready pod -l app=php -n default --timeout=300s
  NEW_PHP_POD=$(kubectl get pod -l app=php -n default -o jsonpath='{.items[0].metadata.name}')
  echo "🔍 Kiểm tra trạng thái pod PHP sau khi khởi động lại..."
  kubectl get pod $NEW_PHP_POD -n default
  echo "✅ [16.4] Khởi động lại pod PHP hoàn tất."
else
  echo "✅ [16.4] Không có thay đổi cấu hình, bỏ qua khởi động lại pod PHP."
fi