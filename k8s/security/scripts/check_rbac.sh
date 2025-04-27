echo "🚀 2 Kiểm tra RBAC..."
echo "🔹 ServiceAccounts:"
kubectl get serviceaccounts -n default
echo "🔹 Roles:"
kubectl get roles -n default
echo "🔹 RoleBindings:"
kubectl get rolebindings -n default
echo "🔹 Quyền của php-app-sa:"
kubectl auth can-i --as system:serviceaccount:default:php-app-sa get pods
echo "🔹 Quyền của php-admin-sa:"
kubectl auth can-i --as system:serviceaccount:default:php-admin-sa get pods
kubectl auth can-i --as system:serviceaccount:default:php-admin-sa update deployments
echo "🔹 Quyền của mysql-sa:"
kubectl auth can-i --as system:serviceaccount:default:mysql-sa get secrets
echo ""