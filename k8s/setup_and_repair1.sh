
# 13. Tạo Ingress
echo "🌐 13.Tạo Ingress cho PHP..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: php-ingress
spec:
  rules:
  - host: doannhanh.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: php-service
            port:
              number: 80
EOF

# Kiểm tra Ingress
echo "🔍 Kiểm tra Ingress..."
kubectl get ingress php-ingress > /dev/null 2>&1 || {
  echo "❌ Không thể tạo Ingress."
  kubectl describe ingress php-ingress
  exit 1
}

# Cập nhật /etc/hosts để truy cập Ingress
echo "🔍 Cập nhật /etc/hosts cho Ingress..."
minikube_ip=$(minikube ip)
echo "$minikube_ip doannhanh.local" | sudo tee -a /etc/hosts || {
  echo "⚠️ Không thể cập nhật /etc/hosts. Vui lòng thêm dòng sau vào /etc/hosts thủ công:"
  echo "$minikube_ip doannhanh.local"
}

# Bước 14: Đợi các pod sẵn sàng với retry logic
echo "⏳ 14.Đợi các pod khởi động..."
max_attempts=30  # Tăng lên 30 lần (300 giây)
attempt=1
while [ $attempt -le $max_attempts ]; do
  echo "🔍 Kiểm tra trạng thái Pod (lần $attempt/$max_attempts)..."
  kubectl get pods
  php_pod=$(kubectl get pods -l app=php -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
  mysql_pod=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
  
  if [ -z "$php_pod" ] || [ -z "$mysql_pod" ]; then
    echo "⚠️ Một hoặc cả hai pod chưa được tạo (PHP: $php_pod, MySQL: $mysql_pod)."
  else
    php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
    mysql_status=$(kubectl get pod $mysql_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
    
    if [ "$php_status" = "CrashLoopBackOff" ] || [ "$mysql_status" = "CrashLoopBackOff" ] || \
       [ "$php_status" = "Error" ] || [ "$mysql_status" = "Error" ]; then
      echo "❌ Pod gặp lỗi nghiêm trọng (PHP: $php_status, MySQL: $mysql_status)."
      kubectl describe pod $php_pod
      kubectl describe pod $mysql_pod
      kubectl logs $php_pod 2>/dev/null || echo "Không có log (PHP pod chưa chạy)."
      kubectl logs $mysql_pod 2>/dev/null || echo "Không có log (MySQL pod chưa chạy)."
      exit 1
    fi
    
    if [ "$php_status" != "Running" ] || [ "$mysql_status" != "Running" ]; then
      echo "⚠️ Một hoặc cả hai pod chưa ở trạng thái Running (PHP: $php_status, MySQL: $mysql_status)."
    else
      php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
      mysql_ready=$(kubectl get pod $mysql_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
      
      if [ "$php_ready" = "true" ] && [ "$mysql_ready" = "true" ]; then
        echo "✅ Tất cả các pod đã sẵn sàng!"
        break
      fi
      echo "⚠️ Pod chưa sẵn sàng (PHP ready: $php_ready, MySQL ready: $mysql_ready)."
    fi
  fi
  
  if [ $attempt -eq $max_attempts ]; then
    echo "❌ Hết thời gian chờ, các pod không sẵn sàng:"
    for pod in $php_pod $mysql_pod; do
      if [ -n "$pod" ]; then
        echo "📝 Chi tiết pod $pod:"
        kubectl describe pod $pod
        echo "📝 Log pod $pod:"
        kubectl logs $pod 2>/dev/null || echo "Không có log (pod chưa chạy)."
      fi
    done
    exit 1
  fi
  
  sleep 10
  attempt=$((attempt + 1))
done
# Bước 15: Kiểm tra cơ sở dữ liệu MySQL
echo "🔍 15.Kiểm tra cơ sở dữ liệu MySQL..."
mysql_pod=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$mysql_pod" ]; then
  echo "❌ Không tìm thấy pod MySQL. Kiểm tra lại deployment."
  kubectl get pods -l app=mysql
  exit 1
fi

mysql_status=$(kubectl get pod $mysql_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
if [ "$mysql_status" != "Running" ]; then
  echo "❌ Pod MySQL ($mysql_pod) chưa ở trạng thái Running (trạng thái: $mysql_status)."
  kubectl describe pod $mysql_pod
  exit 1
fi

mysql_ready=$(kubectl get pod $mysql_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$mysql_ready" != "true" ]; then
  echo "❌ Pod MySQL ($mysql_pod) chưa sẵn sàng (ready: $mysql_ready)."
  kubectl describe pod $mysql_pod
  exit 1
fi

# Kiểm tra trạng thái MySQL server
echo "🔍 Kiểm tra trạng thái MySQL server..."
max_attempts_mysql=3
attempt_mysql=1
while [ $attempt_mysql -le $max_attempts_mysql ]; do
  echo "🔍 Kiểm tra MySQL server (lần $attempt_mysql/$max_attempts_mysql)..."
  if kubectl exec $mysql_pod -- mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} > /dev/null 2>&1; then
    echo "✅ MySQL server đang chạy."
    break
  fi
  
  if [ $attempt_mysql -eq $max_attempts_mysql ]; then
    echo "❌ MySQL server không chạy trong pod $mysql_pod. Thử khởi động lại pod..."
    kubectl delete pod $mysql_pod --grace-period=0 --force
    sleep 30
    mysql_pod=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -z "$mysql_pod" ]; then
      echo "❌ Không thể khởi động lại pod MySQL."
      exit 1
    fi
    echo "📝 Log của pod MySQL mới ($mysql_pod):"
    kubectl logs $mysql_pod 2>/dev/null || echo "Không có log."
    kubectl describe pod $mysql_pod
    exit 1
  fi
  
  sleep 5
  attempt_mysql=$((attempt_mysql + 1))
done

# Kiểm tra kết nối MySQL
echo "🔍 Kiểm tra kết nối MySQL..."
kubectl exec $mysql_pod -- bash -c 'export MYSQL_PWD=userpass; mysql -uapp_user -h localhost -e "SHOW DATABASES;"' || {
  echo "❌ Không thể kết nối đến MySQL."
  kubectl logs $mysql_pod
  exit 1
}
kubectl exec $mysql_pod -- bash -c 'export MYSQL_PWD=userpass; mysql -uapp_user -h localhost -e "SHOW TABLES FROM qlbandoannhanh;"'
# 16. Kiểm tra pod PHP
chmod +x ./k8s/deploy_php_step_16_1.sh
chmod +x ./k8s/deploy_php_step_16_2.sh
chmod +x ./k8s/deploy_php_step_16_3.sh
chmod +x ./k8s/deploy_php_step_16_4.sh
chmod +x ./k8s/deploy_php_step_16_5.sh
chmod +x ./k8s/deploy_php_step_17.sh

./k8s/deploy_php_step_16_1.sh
./k8s/deploy_php_step_16_2.sh
./k8s/deploy_php_step_16_3.sh
./k8s/deploy_php_step_16_4.sh
./k8s/deploy_php_step_16_5.sh
./k8s/deploy_php_step_17.sh


echo "✅ Website PHP hoạt động bình thường."


