# 13. Tạo Ingress
echo "🌐 13. Tạo Ingress cho PHP..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: php-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /  # Đảm bảo rewrite path nếu cần
spec:
  ingressClassName: nginx  # Đảm bảo Ingress Controller (như nginx-ingress) đã được cài đặt
  rules:
  - host: user.doannhanh.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: php-app-service
            port:
              number: 80
  - host: admin.doannhanh.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: php-admin-service
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
echo "$minikube_ip frontend.doannhanh.local admin.doannhanh.local" | sudo tee -a /etc/hosts || {
  echo "⚠️ Không thể cập nhật /etc/hosts. Vui lòng thêm dòng sau vào /etc/hosts thủ công:"
  echo "$minikube_ip frontend.doannhanh.local admin.doannhanh.local"
}

# Bước 14: Đợi các pod sẵn sàng với retry logic
echo "⏳ 14. Đợi các pod khởi động..."
max_attempts=30  # Tối đa 300 giây
attempt=1
while [ $attempt -le $max_attempts ]; do
  echo "🔍 Kiểm tra trạng thái Pod (lần $attempt/$max_attempts)..."
  kubectl get pods
  php_app_pod=$(kubectl get pods -l app=php-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
  php_admin_pod=$(kubectl get pods -l app=php-admin -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
  mysql_pod=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
  
  if [ -z "$php_app_pod" ] || [ -z "$php_admin_pod" ] || [ -z "$mysql_pod" ]; then
    echo "⚠️ Một hoặc nhiều pod chưa được tạo (PHP-App: $php_app_pod, PHP-Admin: $php_admin_pod, MySQL: $mysql_pod)."
  else
    php_app_status=$(kubectl get pod $php_app_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
    php_admin_status=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
    mysql_status=$(kubectl get pod $mysql_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
    
    if [ "$php_app_status" = "CrashLoopBackOff" ] || [ "$php_admin_status" = "CrashLoopBackOff" ] || \
       [ "$mysql_status" = "CrashLoopBackOff" ] || [ "$php_app_status" = "Error" ] || \
       [ "$php_admin_status" = "Error" ] || [ "$mysql_status" = "Error" ]; then
      echo "❌ Pod gặp lỗi nghiêm trọng (PHP-App: $php_app_status, PHP-Admin: $php_admin_status, MySQL: $mysql_status)."
      kubectl describe pod $php_app_pod
      kubectl describe pod $php_admin_pod
      kubectl describe pod $mysql_pod
      kubectl logs $php_app_pod --container php-app 2>/dev/null || echo "Không có log (PHP-App pod chưa chạy)."
      kubectl logs $php_admin_pod --container php-admin 2>/dev/null || echo "Không có log (PHP-Admin pod chưa chạy)."
      kubectl logs $mysql_pod 2>/dev/null || echo "Không có log (MySQL pod chưa chạy)."
      exit 1
    fi
    
    if [ "$php_app_status" != "Running" ] || [ "$php_admin_status" != "Running" ] || [ "$mysql_status" != "Running" ]; then
      echo "⚠️ Một hoặc nhiều pod chưa ở trạng thái Running (PHP-App: $php_app_status, PHP-Admin: $php_admin_status, MySQL: $mysql_status)."
    else
      php_app_ready=$(kubectl get pod $php_app_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
      php_admin_ready=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
      mysql_ready=$(kubectl get pod $mysql_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
      
      if [ "$php_app_ready" = "true" ] && [ "$php_admin_ready" = "true" ] && [ "$mysql_ready" = "true" ]; then
        echo "✅ Tất cả các pod đã sẵn sàng!"
        break
      fi
      echo "⚠️ Pod chưa sẵn sàng (PHP-App ready: $php_app_ready, PHP-Admin ready: $php_admin_ready, MySQL ready: $mysql_ready)."
    fi
  fi
  
  if [ $attempt -eq $max_attempts ]; then
    echo "❌ Hết thời gian chờ, các pod không sẵn sàng:"
    for pod in $php_app_pod $php_admin_pod $mysql_pod; do
      if [ -n "$pod" ]; then
        echo "📝 Chi tiết pod $pod:"
        kubectl describe pod $pod
        echo "📝 Log pod $pod:"
        if [[ "$pod" == *"php-app"* ]]; then
          kubectl logs $pod --container php-app 2>/dev/null || echo "Không có log (pod chưa chạy)."
        elif [[ "$pod" == *"php-admin"* ]]; then
          kubectl logs $pod --container php-admin 2>/dev/null || echo "Không có log (pod chưa chạy)."
        else
          kubectl logs $pod 2>/dev/null || echo "Không có log (pod chưa chạy)."
        fi
      fi
    done
    exit 1
  fi
  
  sleep 10
  attempt=$((attempt + 1))
done


# Bước 15: Kiểm tra cơ sở dữ liệu MySQL
echo "🔍 15. Kiểm tra cơ sở dữ liệu MySQL..."
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

# Kiểm tra Secret mysql-secret
echo "🔍 Kiểm tra Secret mysql-secret..."
kubectl get secret mysql-secret > /dev/null 2>&1 || {
  echo "❌ Secret mysql-secret không tồn tại."
  kubectl describe secret mysql-secret
  exit 1
}

# Lấy thông tin từ Secret
echo "🔍 Lấy thông tin từ Secret mysql-secret..."
MYSQL_ROOT_PASSWORD=$(kubectl get secret mysql-secret -o jsonpath='{.data.root-password}' | base64 -d)
MYSQL_USER=$(kubectl get secret mysql-secret -o jsonpath='{.data.username}' | base64 -d)
MYSQL_USER_PASSWORD=$(kubectl get secret mysql-secret -o jsonpath='{.data.user-password}' | base64 -d)

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "❌ Không tìm thấy key 'root-password' trong Secret mysql-secret."
  kubectl describe secret mysql-secret
  exit 1
fi
if [ -z "$MYSQL_USER" ]; then
  echo "❌ Không tìm thấy key 'username' trong Secret mysql-secret."
  kubectl describe secret mysql-secret
  exit 1
fi
if [ -z "$MYSQL_USER_PASSWORD" ]; then
  echo "❌ Không tìm thấy key 'user-password' trong Secret mysql-secret."
  kubectl describe secret mysql-secret
  exit 1
fi

# Kiểm tra trạng thái MySQL server
echo "🔍 Kiểm tra trạng thái MySQL server..."
max_attempts_mysql=3
attempt_mysql=1
while [ $attempt_mysql -le $max_attempts_mysql ]; do
  echo "🔍 Kiểm tra MySQL server (lần $attempt_mysql/$max_attempts_mysql)..."
  if kubectl exec $mysql_pod -- mysqladmin ping -h localhost -u root -p"$MYSQL_ROOT_PASSWORD" > /dev/null 2>&1; then
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
kubectl exec $mysql_pod -- bash -c "export MYSQL_PWD='$MYSQL_USER_PASSWORD'; mysql -u$MYSQL_USER -h localhost -e 'SHOW DATABASES;'" || {
  echo "❌ Không thể kết nối đến MySQL."
  kubectl logs $mysql_pod
  exit 1
}

# Kiểm tra bảng trong database qlbandoannhanh
kubectl exec $mysql_pod -- bash -c "export MYSQL_PWD='$MYSQL_USER_PASSWORD'; mysql -u$MYSQL_USER -h localhost -e 'SHOW TABLES FROM qlbandoannhanh;'" || {
  echo "❌ Không thể truy vấn bảng từ database qlbandoannhanh."
  kubectl logs $mysql_pod
  exit 1
}


# 16. Kiểm tra pod PHP

#!/bin/bash

# Kiểm tra nếu thư mục k8s tồn tại thì dùng đường dẫn ./k8s/
if [ -d "./k8s" ]; then
  prefix="./k8s/"
else
  prefix="./"
fi

# Cấp quyền cho các file cần thiết

chmod +x ${prefix}deploy_php_step_16_1.sh
chmod +x ${prefix}deploy_php_step_16_2.sh
chmod +x ${prefix}deploy_php_step_16_3.sh
chmod +x ${prefix}deploy_php_step_16_4.sh
chmod +x ${prefix}deploy_php_step_16_5.sh
chmod +x ${prefix}deploy_php_step_17.sh

# Chạy các file theo thứ tự
${prefix}deploy_php_step_16_1.sh
# ${prefix}deploy_php_step_16_2.sh
# ${prefix}deploy_php_step_16_3.sh
${prefix}deploy_php_step_16_4.sh
${prefix}deploy_php_step_16_5.sh
${prefix}deploy_php_step_17.sh

echo "✅ Website PHP hoạt động bình thường."


