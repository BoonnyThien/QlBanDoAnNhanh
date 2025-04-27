echo "🚀 3 Kiểm tra Network Policies..."
kubectl get networkpolicies -n default
echo "🔹 Chi tiết Network Policies:"
kubectl describe networkpolicies -n default
echo ""