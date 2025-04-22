# Bước 16.5: Tạo Service cho PHP
echo "🔄 16.5. Tạo PHP Service..."
if kubectl get service php-service -n default > /dev/null 2>&1; then
  if [ "$FORCE_RECREATE" = "true" ]; then
    echo "⚠️ Service php-service đã tồn tại, xóa và tạo lại..."
    kubectl delete service php-service -n default
  else
    echo "✅ Service php-service đã tồn tại, bỏ qua bước tạo."
  fi
fi
if ! kubectl get service php-service -n default > /dev/null 2>&1; then
  cat > php-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: php-service
spec:
  selector:
    app: php
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
  kubectl apply -f php-service.yaml || {
    echo "❌ Không thể tạo Service php-service."
    exit 1
  }
  echo "✅ Service php-service đã được tạo."
fi