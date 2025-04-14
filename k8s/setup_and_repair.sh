#!/bin/bash

# 1. Kiểm tra trạng thái Minikube và khởi động lại nếu cần
echo "🚀 1.Kiểm tra và khởi động Minikube..."
minikube_status=$(minikube status | grep host | awk '{print $2}' 2>/dev/null || echo "NotRunning")
if [ "$minikube_status" != "Running" ]; then
    echo "Minikube không chạy, khởi động lại..."
    minikube stop 2>/dev/null || true
    minikube delete --purge 2>/dev/null || true
    minikube start --driver=docker --memory=3072 --cpus=2 --addons=ingress
    # Không cần mount thư mục nữa vì mã nguồn đã nằm trong Docker image
    # Đảm bảo quyền cho thư mục minikube
    [ -d ~/.minikube ] && chmod -R 755 ~/.minikube
else
    echo "Minikube đã chạy, tiếp tục triển khai..."
fi

echo "⏳ Đợi Minikube khởi động hoàn tất..."
sleep 10
kubectl cluster-info

# 2. Dọn dẹp tài nguyên cũ
echo "🧹 2.Dọn dẹp tài nguyên cũ..."
kubectl delete --all deployments,statefulsets,services,pods,pvc,pv,configmaps,secrets,jobs,ingresses --grace-period=0 --force --ignore-not-found=true

echo "⏳ Đợi tài nguyên xóa hoàn tất..."
sleep 5

echo "🔍 Kiểm tra tài nguyên còn sót lại..."
kubectl get services

# 3. Tạo Secret cho MySQL
echo "🔒 3.Tạo MySQL Secret..."
kubectl create secret generic mysql-secret \
  --from-literal=root-password=rootpassword \
  --from-literal=user-password=userpass \
  --from-literal=username=app_user

# 4. Kiểm tra khả năng kéo Docker image từ Docker Hub
echo "📦 4.Kiểm tra khả năng kéo Docker image từ Docker Hub..."
docker pull buithienboo/qlbandoannhanh-php-app:1.1 || {
    echo "❌ Không thể kéo image buithienboo/qlbandoannhanh-php-app:1.1 từ Docker Hub."
    echo "🔍 Vui lòng kiểm tra kết nối mạng hoặc xác nhận image tồn tại trên Docker Hub."
    exit 1
}
echo "✅ Đã kéo thành công image buithienboo/qlbandoannhanh-php-app:1.1"

# 5. Kiểm tra nội dung image (tùy chọn, để đảm bảo image chứa mã nguồn)
echo "🔍 5.Kiểm tra nội dung image buithienboo/qlbandoannhanh-php-app:1.1..."
docker run --rm -it buithienboo/qlbandoannhanh-php-app:1.1 bash -c "ls -l /var/www/html/index.php" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ File index.php tồn tại trong image tại /var/www/html/"
else
    echo "❌ File index.php không tồn tại trong image tại /var/www/html/"
    echo "🔍 Nội dung thư mục /var/www/html trong image:"
    docker run --rm -it buithienboo/qlbandoannhanh-php-app:1.1 bash -c "ls -la /var/www/html/"
    exit 1
fi

# Kiểm tra file SQL trong image
docker run --rm -it buithienboo/qlbandoannhanh-php-app:1.1 bash -c "ls -l /var/www/html/database/qlbandoannhanh.sql" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ File qlbandoannhanh.sql tồn tại trong image tại /var/www/html/database/"
else
    echo "❌ File qlbandoannhanh.sql không tồn tại trong image tại /var/www/html/database/"
    echo "🔍 Nội dung thư mục /var/www/html/database trong image:"
    docker run --rm -it buithienboo/qlbandoannhanh-php-app:1.1 bash -c "ls -la /var/www/html/database/"
    exit 1
fi

echo "✅ Đã kiểm tra thành công nội dung image buithienboo/qlbandoannhanh-php-app:1.1"

# 6. Tạo ConfigMap từ file qlbandoannhanh.sql trực tiếp từ WSL
echo "📦 6.Tạo ConfigMap cho khởi tạo MySQL từ file trên WSL..."
kubectl create configmap mysql-init --from-file=init.sql="$SQL_FILE"

# 7. Tạo ConfigMap cho cấu hình MySQL (để sửa mã hóa)
echo "🔧 7.Tạo ConfigMap cho cấu hình MySQL..."
cat > mysql-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  my.cnf: |
    [mysqld]
    # Tạm thời bỏ cấu hình mã hóa để tránh xung đột
    # character-set-server=utf8mb4
    # collation-server=utf8mb4_unicode_ci
    [client]
    # default-character-set=utf8mb4
    [mysql]
    # default-character-set=utf8mb4
EOF
kubectl apply -f mysql-config.yaml

# 8. Tạo MySQL Deployment
echo "🛢️ 8.Tạo MySQL Deployment..."
cat > mysql-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: root-password
        - name: MYSQL_DATABASE
          value: qlbandoannhanh
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: username
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: user-password
        ports:
        - containerPort: 3306
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1"
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
        - name: mysql-initdb
          mountPath: /docker-entrypoint-initdb.d
        - name: mysql-config
          mountPath: /etc/mysql/conf.d
        command: ["/bin/sh", "-c"]
        args:
        - |
          mkdir -p /var/run/mysqld && \
          chown mysql:mysql /var/run/mysqld && \
          chmod 755 /var/run/mysqld && \
          chown -R mysql:mysql /var/lib/mysql && \
          chmod -R 700 /var/lib/mysql && \
          exec /usr/local/bin/docker-entrypoint.sh mysqld
        livenessProbe:
          tcpSocket:
            port: 3306
          initialDelaySeconds: 60  # Tăng thời gian chờ
          periodSeconds: 10
          failureThreshold: 3
        readinessProbe:
          tcpSocket:
            port: 3306
          initialDelaySeconds: 30
          periodSeconds: 5
          failureThreshold: 3
      volumes:
      - name: mysql-storage
        emptyDir: {}
      - name: mysql-initdb
        configMap:
          name: mysql-init
      - name: mysql-config
        configMap:
          name: mysql-config
EOF
kubectl apply -f mysql-deployment.yaml

# 9. Tạo MySQL Service
echo "🔄 9.Tạo MySQL Service..."
cat > mysql-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
  type: ClusterIP
EOF
kubectl apply -f mysql-service.yaml

# 10. Tạo ConfigMap cho cấu hình Apache
echo "🔧 10.Tạo ConfigMap cho cấu hình Apache..."
cat > apache-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: apache-config
data:
  apache.conf: |
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
EOF
kubectl apply -f apache-config.yaml
# 10.5. Tạo ConfigMap cho MySQL từ file trong image Docker
echo "📜 10.5 Tạo ConfigMap mysql-init để khởi tạo dữ liệu MySQL từ image Docker..."

# Kiểm tra docker đã được cài đặt chưa
if ! command -v docker &> /dev/null; then
    echo "❌ Docker không được cài đặt. Vui lòng cài đặt Docker để tiếp tục."
    exit 1
fi

# Tải image từ Docker Hub
echo "🔍 Tải image buithienboo/qlbandoannhanh-php-app:1.1 từ Docker Hub..."
docker pull buithienboo/qlbandoannhanh-php-app:1.1 || {
    echo "❌ Không thể tải image buithienboo/qlbandoannhanh-php-app:1.1."
    exit 1
}

# Chạy container tạm thời để copy file
echo "🔍 Chạy container tạm thời để lấy file qlbandoannhanh.sql..."
docker run --rm -d --name temp-php-container buithienboo/qlbandoannhanh-php-app:1.1 tail -f /dev/null || {
    echo "❌ Không thể chạy container từ image buithienboo/qlbandoannhanh-php-app:1.1."
    exit 1
}

# Copy file từ container ra máy host
echo "🔍 Copy file qlbandoannhanh.sql từ container..."
docker cp temp-php-container:/var/www/html/database/qlbandoannhanh.sql /tmp/qlbandoannhanh.sql || {
    echo "❌ Không thể copy file qlbandoannhanh.sql từ container."
    docker stop temp-php-container
    exit 1
}

# Dừng container
echo "🔍 Dừng container tạm thời..."
docker stop temp-php-container || {
    echo "⚠️ Không thể dừng container, nhưng tiếp tục quy trình..."
}

# Tạo ConfigMap từ file copy
echo "📜 Tạo ConfigMap mysql-init từ file copy..."
if [ -f "/tmp/qlbandoannhanh.sql" ]; then
    kubectl create configmap mysql-init --from-file=/tmp/qlbandoannhanh.sql || {
        echo "❌ Không thể tạo ConfigMap mysql-init."
        rm -f /tmp/qlbandoannhanh.sql
        exit 1
    }
    # Xóa file tạm
    rm -f /tmp/qlbandoannhanh.sql
else
    echo "❌ File /tmp/qlbandoannhanh.sql không tồn tại sau khi copy."
    exit 1
fi

# Kiểm tra ConfigMap vừa tạo
echo "🔍 Kiểm tra ConfigMap mysql-init..."
kubectl get configmap mysql-init > /dev/null 2>&1 || {
    echo "❌ ConfigMap mysql-init không được tạo thành công."
    kubectl describe configmap mysql-init
    exit 1
}

echo "✅ ConfigMap mysql-init đã được tạo thành công."

# 11. Tạo PHP Deployment
echo "🚀 11.1 Tạo PHP Deployment..."
cat > php-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-deployment
  labels:
    app: php
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php
  template:
    metadata:
      labels:
        app: php
    spec:
      containers:
      - name: php
        image: buithienboo/qlbandoannhanh-php-app:1.1
        ports:
        - containerPort: 80
        volumeMounts:
        - name: php-ini
          mountPath: /usr/local/etc/php/conf.d/custom-php.ini
          subPath: php.ini
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "200m"
            memory: "256Mi"
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 10
      volumes:
      - name: php-ini
        configMap:
          name: php-config
EOF
kubectl apply -f php-deployment.yaml

# 11. Tạo ConfigMap cho PHP
echo "📜 11.2 Tạo ConfigMap cho PHP..."
cat > /tmp/php.ini << EOF
[PHP]
default_charset = "UTF-8"
memory_limit = 256M
upload_max_filesize = 20M
post_max_size = 20M
max_execution_time = 60
EOF

kubectl create configmap php-config --from-file=php.ini=/tmp/php.ini || {
  echo "❌ Không thể tạo ConfigMap php-config."
  exit 1
}

rm /tmp/php.ini

# Kiểm tra ConfigMap vừa tạo
echo "🔍 Kiểm tra ConfigMap php-config..."
kubectl get configmap php-config > /dev/null 2>&1 || {
  echo "❌ ConfigMap php-config không được tạo thành công."
  kubectl describe configmap php-config
  exit 1
}

echo "✅ ConfigMap php-config đã được tạo thành công."

#!/bin/bash

# 12. Tạo deployment PHP
./k8s/deploy_php_step_12_1.sh
./k8s/deploy_php_step_12_2.sh
# ./k8s/deploy_php_step_12_3.sh
# ./k8s/deploy_php_step_12_4.sh
./k8s/deploy_php_step_12_5.sh
./k8s/deploy_php_step_12_6.sh

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

# 14. Đợi các pod sẵn sàng với retry logic
echo "⏳ 14.Đợi các pod khởi động..."
max_attempts=10
attempt=1
while [ $attempt -le $max_attempts ]; do
  echo "🔍 Kiểm tra trạng thái Pod (lần $attempt/$max_attempts)..."
  kubectl get pods
  php_pod=$(kubectl get pods -l app=php-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
  mysql_pod=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
  
  # Đảm bảo cả hai pod tồn tại
  if [ -z "$php_pod" ] || [ -z "$mysql_pod" ]; then
    echo "⚠️ Một hoặc cả hai pod chưa được tạo (PHP: $php_pod, MySQL: $mysql_pod)."
  else
    # Kiểm tra trạng thái pod trước khi kiểm tra ready
    php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
    mysql_status=$(kubectl get pod $mysql_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
    
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
    if [ -n "$php_pod" ]; then
      echo "📝 Chi tiết pod PHP ($php_pod):"
      kubectl describe pod $php_pod
      echo "📝 Log pod PHP:"
      kubectl logs $php_pod 2>/dev/null || echo "Không có log (pod chưa chạy)."
    fi
    if [ -n "$mysql_pod" ]; then
      echo "📝 Chi tiết pod MySQL ($mysql_pod):"
      kubectl describe pod $mysql_pod
      echo "📝 Log pod MySQL:"
      kubectl logs $mysql_pod 2>/dev/null || echo "Không có log (pod chưa chạy)."
    fi
    exit 1
  fi
  
  sleep 10
  attempt=$((attempt + 1))
done

# 15. Kiểm tra cơ sở dữ liệu MySQL
echo "🔍 15.Kiểm tra cơ sở dữ liệu MySQL..."
mysql_pod=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}')

# Đảm bảo pod MySQL sẵn sàng trước khi kiểm tra
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

# Kiểm tra tài nguyên Minikube
echo "🔍 Kiểm tra tài nguyên Minikube..."
minikube ssh -- "free -h" || echo "Không thể kiểm tra tài nguyên Minikube."
minikube ssh -- "top -bn1 | head -n 5" || echo "Không thể kiểm tra CPU usage."

# Kiểm tra xem MySQL server có đang chạy không
echo "🔍 Kiểm tra trạng thái MySQL server..."
max_attempts_mysql=30
attempt_mysql=1
while [ $attempt_mysql -le $max_attempts_mysql ]; do
  echo "🔍 Kiểm tra MySQL server (lần $attempt_mysql/$max_attempts_mysql)..."
  # Thay ps bằng cách kiểm tra file PID hoặc socket
  if kubectl exec $mysql_pod -- bash -c '[ -f /var/run/mysqld/mysqld.pid ] || [ -S /var/run/mysqld/mysqld.sock ]' > /dev/null 2>&1; then
    echo "✅ MySQL server đang chạy."
    break
  fi
  
  if [ $attempt_mysql -eq $max_attempts_mysql ]; then
    echo "❌ MySQL server không chạy trong pod $mysql_pod."
    echo "📝 Log của pod MySQL (bao gồm lỗi từ init.sql nếu có):"
    kubectl logs $mysql_pod | grep -i "error" || echo "Không tìm thấy lỗi cụ thể trong log."
    echo "📝 Toàn bộ log của pod MySQL:"
    kubectl logs $mysql_pod
    echo "📝 Chi tiết pod MySQL:"
    kubectl describe pod $mysql_pod
    echo "🔍 Kiểm tra file init.sql trong pod:"
    kubectl exec $mysql_pod -- cat /docker-entrypoint-initdb.d/init.sql || echo "Không thể đọc file init.sql."
    echo "🔍 Kiểm tra file PID của MySQL:"
    kubectl exec $mysql_pod -- bash -c 'if [ -f /var/run/mysqld/mysqld.pid ]; then echo "File PID tồn tại."; else echo "File PID không tồn tại."; fi'
    echo "🔍 Kiểm tra trạng thái port 3306 bằng kết nối thử:"
    kubectl exec $mysql_pod -- bash -c 'echo "quit" | mysql -h localhost -P 3306 -u root -p${MYSQL_ROOT_PASSWORD}' || echo "Không thể kết nối đến port 3306."
    exit 1
  fi
  
  sleep 5
  attempt_mysql=$((attempt_mysql + 1))
done

# Kiểm tra socket MySQL
echo "🔍 Kiểm tra socket MySQL..."
kubectl exec $mysql_pod -- bash -c 'if [ -S /var/run/mysqld/mysqld.sock ]; then echo "Socket /var/run/mysqld/mysqld.sock tồn tại."; else echo "Socket /var/run/mysqld/mysqld.sock không tồn tại."; fi'

# Thử kết nối qua TCP thay vì socket
kubectl exec $mysql_pod -- bash -c 'export MYSQL_PWD=userpass; mysql -uapp_user -h localhost -e "SHOW VARIABLES LIKE \"character_set%\";"' || {
  echo "❌ Không thể kết nối đến MySQL qua TCP. Log pod MySQL:"
  kubectl logs $mysql_pod
  exit 1
}
kubectl exec $mysql_pod -- bash -c 'export MYSQL_PWD=userpass; mysql -uapp_user -h localhost -e "SHOW VARIABLES LIKE \"collation%\";"'
kubectl exec $mysql_pod -- bash -c 'export MYSQL_PWD=userpass; mysql -uapp_user -h localhost -e "SHOW TABLES FROM qlbandoannhanh;"'
kubectl exec $mysql_pod -- bash -c 'export MYSQL_PWD=userpass; mysql -uapp_user -h localhost -e "SELECT * FROM qlbandoannhanh.categories LIMIT 5;"' 2>/dev/null || true
kubectl exec $mysql_pod -- bash -c 'export MYSQL_PWD=userpass; mysql -uapp_user -h localhost -e "SELECT * FROM qlbandoannhanh.products LIMIT 5;"' 2>/dev/null || true

# 16. Kiểm tra pod PHP
./k8s/deploy_php_step_16_1.sh
./k8s/deploy_php_step_16_2.sh
./k8s/deploy_php_step_16_3.sh
./k8s/deploy_php_step_16_4.sh

echo "✅ Website PHP hoạt động bình thường."

# 17. Kiểm tra URL truy cập

# ./k8s/deploy_php_step_17.sh

#!/bin/bash

#!/bin/bash

# 18. Thêm tên miền vào /etc/hosts để truy cập dịch vụ PHP
echo "🚀 [18] Thêm tên miền vào /etc/hosts để truy cập dịch vụ PHP..."

# Đọc tên pod từ file tạm (để kiểm tra pod trước)
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod trước khi tiếp tục
echo "🔍 Kiểm tra trạng thái pod PHP..."
php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng."
  echo "🔍 Trạng thái pod: $php_status"
  echo "🔍 Trạng thái ready: $php_ready"
  echo "🔍 Chi tiết pod:"
  kubectl describe pod $php_pod
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
fi

# Kiểm tra xem dịch vụ php-service có tồn tại không
echo "🔍 Kiểm tra dịch vụ php-service..."
kubectl get service php-service -n default >/dev/null 2>&1 || {
  echo "❌ Dịch vụ php-service không tồn tại."
  echo "🔍 Danh sách dịch vụ:"
  kubectl get service -n default
  exit 1
}

# Kiểm tra xem minikube tunnel có đang chạy không
echo "🔍 Kiểm tra xem minikube tunnel có đang chạy không..."
if ! pgrep -f "minikube tunnel" > /dev/null; then
  echo "⚠️ minikube tunnel không chạy. Khởi động minikube tunnel..."
  minikube tunnel > /dev/null 2>&1 &
  sleep 5  # Đợi tunnel khởi động
  if ! pgrep -f "minikube tunnel" > /dev/null; then
    echo "❌ Không thể khởi động minikube tunnel. Hãy chạy 'minikube tunnel' trong một terminal riêng biệt."
    exit 1
  fi
  echo "✅ minikube tunnel đã được khởi động."
fi

# Lấy URL của dịch vụ php-service
echo "🔍 Lấy URL của dịch vụ php-service..."
service_url=$(minikube service php-service -n default --url | head -n 1)
if [ -z "$service_url" ]; then
  echo "❌ Không thể lấy URL của dịch vụ php-service."
  echo "🔍 Danh sách dịch vụ trong Minikube:"
  minikube service list
  exit 1
fi
echo "🔍 URL của dịch vụ: $service_url"

# Trích xuất IP và cổng từ URL (dạng http://IP:PORT)
service_ip=$(echo $service_url | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
service_port=$(echo $service_url | grep -oE ':[0-9]+' | tr -d ':')
if [ -z "$service_ip" ] || [ -z "$service_port" ]; then
  echo "❌ Không thể trích xuất IP hoặc cổng từ URL: $service_url"
  exit 1
fi
echo "🔍 IP: $service_ip"
echo "🔍 Port: $service_port"

# Tên miền tùy chỉnh
custom_domain="php.local"

# Kiểm tra xem /etc/hosts đã có ánh xạ này chưa
echo "🔍 Kiểm tra xem /etc/hosts đã có ánh xạ cho $custom_domain chưa..."
if sudo grep -q "$custom_domain" /etc/hosts; then
  echo "🔍 /etc/hosts đã có ánh xạ cho $custom_domain. Cập nhật ánh xạ..."
  sudo sed -i "/$custom_domain/d" /etc/hosts
fi

# Thêm ánh xạ mới vào /etc/hosts
echo "🔍 Thêm ánh xạ $custom_domain vào /etc/hosts..."
echo "$service_ip $custom_domain" | sudo tee -a /etc/hosts || {
  echo "❌ Không thể thêm ánh xạ vào /etc/hosts. Vui lòng kiểm tra quyền sudo."
  exit 1
}

# Kiểm tra kết nối với tên miền
echo "🔍 Kiểm tra kết nối với $custom_domain:$service_port..."
curl --connect-timeout 5 "http://$custom_domain:$service_port" >/dev/null 2>&1 || {
  echo "⚠️ Không thể truy cập $custom_domain:$service_port. Kiểm tra lại cấu hình."
  echo "🔍 Nội dung /etc/hosts:"
  cat /etc/hosts | grep $custom_domain
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

echo "✅ [18] Đã thêm tên miền $custom_domain vào /etc/hosts."
echo "🔗 Truy cập website PHP tại: http://$custom_domain:$service_port"