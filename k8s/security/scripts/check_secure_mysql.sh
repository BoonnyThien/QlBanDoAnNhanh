echo "7️ Kiểm tra MySQL Hardening..."
MYSQL_POD=$(kubectl get pods -n default -l app=mysql -o name | head -n 1)
if [ -n "$MYSQL_POD" ]; then
  echo "🔹 Biến SSL của MySQL:"
  kubectl exec -it $MYSQL_POD -- mysql -u root -prootpass -e "SHOW VARIABLES LIKE '%ssl%'"
  echo "🔹 Giới hạn kết nối MySQL:"
  kubectl exec -it $MYSQL_POD -- mysql -u root -prootpass -e "SHOW VARIABLES LIKE 'max_connections'"
  echo "🔹 Slow query log của MySQL:"
  kubectl exec -it $MYSQL_POD -- cat /var/log/mysql/slow.log 2>/dev/null || echo "Chưa có slow query log."
  echo "🔹 Kiểm tra require_secure_transport:"
  kubectl exec -it $MYSQL_POD -- mysql -u root -prootpass -e "SHOW VARIABLES LIKE 'require_secure_transport'"
else
  echo "⚠️ Không tìm thấy pod MySQL."
fi
echo ""