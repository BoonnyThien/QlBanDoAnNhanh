echo "9️ Kiểm tra Monitoring..."
echo "🔹 ServiceMonitors:"
kubectl get servicemonitors -n default
echo "🔹 Prometheus Pods:"
kubectl get pods -n default -l app=prometheus
echo "🔹 Prometheus Service:"
kubectl get service prometheus -n default
echo "🔹 Prometheus Targets (kiểm tra thủ công qua UI):"
minikube service prometheus --url
echo ""