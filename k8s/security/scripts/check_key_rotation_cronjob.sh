echo "14 Kiểm tra và áp dụng CronJob cho Key Rotation..."
if ! kubectl get cronjob key-rotation -n default 2>/dev/null; then
  echo "🔹 Tạo CronJob key-rotation..."
  kubectl apply -f k8s/security/key-rotation-cronjob.yaml
else
  echo "✅ CronJob key-rotation đã tồn tại."
fi
kubectl get cronjob key-rotation -n default
echo ""