echo "15 Kiểm tra trạng thái tổng thể..."
echo "🔹 Pods (default namespace):"
kubectl get pods -n default
echo "🔹 Pods (velero namespace):"
kubectl get pods -n velero
echo "🔹 Pods (falco namespace):"
kubectl get pods -n falco
echo "🔹 Secrets:"
kubectl get secrets -n default
echo "🔹 Network Policies:"
kubectl get networkpolicies -n default
echo "🔹 Service Monitors:"
kubectl get servicemonitors -n default
echo ""

echo "✅ Hoàn tất kiểm tra bảo mật!"