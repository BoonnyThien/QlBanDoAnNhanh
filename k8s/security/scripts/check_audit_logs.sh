echo "12 Kiểm tra Audit Logs..."
echo "🔹 Audit logs trong Minikube:"
minikube ssh "sudo cat /var/log/kubernetes/audit.log | tail -n 10" 2>/dev/null || echo "⚠️ Không thể truy cập audit logs."
echo ""