echo "8️ Kiểm tra Auth Service..."
echo "🔹 Pods:"
kubectl get pods -n default -l app=auth-service
echo "🔹 Service:"
kubectl get service auth-service -n default
echo "🔹 JWT_SECRET:"
kubectl get secret auth-service-secrets -n default -o jsonpath="{.data.JWT_SECRET}" | base64 -d
echo "🔹 Logs:"
kubectl logs -n default -l app=auth-service --tail=10
echo ""