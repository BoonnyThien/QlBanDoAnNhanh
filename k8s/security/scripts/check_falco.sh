echo "11 Kiểm tra Falco..."
echo "🔹 Falco Pods:"
kubectl get pods -n falco -l app=falco
echo "🔹 Falco Logs (các sự kiện bất thường):"
kubectl logs -n falco -l app=falco --tail=10
echo ""