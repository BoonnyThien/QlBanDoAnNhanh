#!/bin/bash

echo "🚀 10 Thiết lập Falco..."

# Cài Falco
kubectl apply -f k8s/security/falco.yaml
if [ $? -eq 0 ]; then
  echo "✅ Falco triển khai thành công!"
else
  echo "❌ Lỗi khi triển khai Falco!"
  exit 1
fi

# Đợi Pods sẵn sàng
echo "⏳ Đợi Falco Pods sẵn sàng..."
kubectl wait --for=condition=ready pod -l app=falco -n falco --timeout=300s
if [ $? -eq 0 ]; then
  echo "✅ Falco Pods sẵn sàng!"
else
  echo "❌ Lỗi: Falco Pods không sẵn sàng!"
  kubectl get pods -n falco -l app=falco
  kubectl logs -n falco -l app=falco
  exit 1
fi

echo "✅ Hoàn tất thiết lập Falco!"