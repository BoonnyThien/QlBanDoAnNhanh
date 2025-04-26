echo "4️ Kiểm tra Secrets..."
echo "🔹 Danh sách Secrets:"
kubectl get secrets -n default
echo "🔹 Giá trị DB_HOST của php-app-secrets:"
kubectl get secret php-app-secrets -n default -o jsonpath="{.data.DB_HOST}" | base64 -d
echo "🔹 Giá trị DB_HOST của php-admin-secrets:"
kubectl get secret php-admin-secrets -n default -o jsonpath="{.data.DB_HOST}" | base64 -d
echo "🔹 Giá trị MYSQL_ROOT_PASSWORD của mysql-secrets:"
kubectl get secret mysql-secrets -n default -o jsonpath="{.data.MYSQL_ROOT_PASSWORD}" | base64 -d
echo ""