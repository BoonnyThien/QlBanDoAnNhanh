echo "🚀 13 Kiểm tra Key Rotation..."
echo "🔹 Giá trị MYSQL_PASSWORD trong mysql-secrets:"
kubectl get secret mysql-secrets -n default -o jsonpath="{.data.MYSQL_PASSWORD}" | base64 -d
echo "🔹 Giá trị DB_PASSWORD trong php-app-secrets:"
kubectl get secret php-app-secrets -n default -o jsonpath="{.data.DB_PASSWORD}" | base64 -d
echo "🔹 Giá trị DB_PASSWORD trong php-admin-secrets:"
kubectl get secret php-admin-secrets -n default -o jsonpath="{.data.DB_PASSWORD}" | base64 -d
echo ""