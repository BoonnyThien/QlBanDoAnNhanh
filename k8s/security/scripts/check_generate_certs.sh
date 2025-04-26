echo "6️ Kiểm tra TLS Certificates..."
echo "🔹 Secret chứa chứng chỉ TLS:"
kubectl get secrets -n default | grep tls
echo "🔹 Thời hạn chứng chỉ tls-secret:"
kubectl get secret tls-secret -n default -o jsonpath="{.data.tls\.crt}" | base64 -d | openssl x509 -noout -dates
echo "🔹 Thời hạn chứng chỉ app-tls:"
kubectl get secret app-tls -n default -o jsonpath="{.data.tls\.crt}" | base64 -d | openssl x509 -noout -dates
echo ""