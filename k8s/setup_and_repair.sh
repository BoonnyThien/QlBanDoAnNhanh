#!/bin/bash
# setup_and_repair.sh

# 1. Kiểm tra trạng thái Minikube và khởi động lại nếu cần
echo "🚀 1.Kiểm tra và khởi động Minikube..."
minikube_status=$(minikube status | grep host | awk '{print $2}' 2>/dev/null || echo "NotRunning")
if [ "$minikube_status" != "Running" ]; then
    echo "Minikube không chạy, khởi động lại..."
    minikube stop 2>/dev/null || true
    minikube delete --purge 2>/dev/null || true
    minikube start --driver=docker --memory=2200 --cpus=4 --addons=ingress
    # Không cần mount thư mục nữa vì mã nguồn đã nằm trong Docker image
    # Đảm bảo quyền cho thư mục minikube
    [ -d ~/.minikube ] && chmod -R 755 ~/.minikube
else
    echo "Minikube đã chạy, tiếp tục triển khai..."
fi

echo "⏳ Đợi Minikube khởi động hoàn tất..."
sleep 10
kubectl cluster-info

# 2. Dọn dẹp tài nguyên cũ và đảm bảo xóa xong mới tiếp tục
echo "🧹 2.Dọn dẹp tài nguyên cũ..."
kubectl delete --all deployments,statefulsets,services,pods,pvc,pv,configmaps,secrets,jobs,ingresses --ignore-not-found=true || {
  echo "⚠️ Không thể xóa một số tài nguyên cũ, nhưng tiếp tục..."
}

echo "⏳ Đợi tài nguyên xóa hoàn tất..."
max_attempts=30  # Tối đa 300 giây (5 phút)
attempt=1
while [ $attempt -le $max_attempts ]; do
  # Kiểm tra các tài nguyên còn sót lại
  pod_count=$(kubectl get pods --no-headers 2>/dev/null | wc -l)
  deployment_count=$(kubectl get deployments --no-headers 2>/dev/null | wc -l)
  service_count=$(kubectl get services --no-headers 2>/dev/null | grep -v "kubernetes" | wc -l)  # Bỏ qua service "kubernetes"
  pvc_count=$(kubectl get pvc --no-headers 2>/dev/null | wc -l)
  pv_count=$(kubectl get pv --no-headers 2>/dev/null | wc -l)
  configmap_count=$(kubectl get configmaps --no-headers 2>/dev/null | grep -v "kube-root-ca.crt" | wc -l)  # Bỏ qua configmap hệ thống
  secret_count=$(kubectl get secrets --no-headers 2>/dev/null | grep -v "default-token" | wc -l)  # Bỏ qua secret hệ thống
  ingress_count=$(kubectl get ingresses --no-headers 2>/dev/null | wc -l)

  # Kiểm tra xem tất cả tài nguyên đã được xóa chưa
  if [ "$pod_count" -eq 0 ] && [ "$deployment_count" -eq 0 ] && [ "$service_count" -eq 0 ] && \
     [ "$pvc_count" -eq 0 ] && [ "$pv_count" -eq 0 ] && [ "$configmap_count" -eq 0 ] && \
     [ "$secret_count" -eq 0 ] && [ "$ingress_count" -eq 0 ]; then
    echo "✅ Tất cả tài nguyên cũ đã được xóa."
    break
  fi

  echo "🔍 Tài nguyên còn sót lại (lần $attempt/$max_attempts):"
  echo "  Pods: $pod_count, Deployments: $deployment_count, Services: $service_count, PVCs: $pvc_count, PVs: $pv_count, ConfigMaps: $configmap_count, Secrets: $secret_count, Ingresses: $ingress_count"
  
  # Nếu còn tài nguyên, in chi tiết để debug
  if [ "$pod_count" -gt 0 ]; then
    echo "📋 Pods còn lại:"
    kubectl get pods
  fi
  if [ "$service_count" -gt 0 ]; then
    echo "📋 Services còn lại:"
    kubectl get services
  fi

  # Nếu hết thời gian chờ, thoát với lỗi
  if [ $attempt -eq $max_attempts ]; then
    echo "❌ Hết thời gian chờ, một số tài nguyên vẫn chưa được xóa:"
    kubectl get all
    kubectl get pvc,pv,configmaps,secrets,ingresses
    exit 1
  fi

  sleep 10
  attempt=$((attempt + 1))
done

# 3. Tạo Secret cho MySQL
echo "🔒 3. Tạo MySQL Secret..."

# Xóa Secret cũ nếu tồn tại
kubectl delete secret mysql-secret -n default --ignore-not-found

# Tạo file YAML tạm thời
cat <<EOF > mysql-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: default
type: Opaque
data:
  root-password: $(echo -n 'rootpass' | base64)
  user-password: $(echo -n 'userpass' | base64)
EOF

# Áp dụng Secret
kubectl apply -f mysql-secret.yaml || {
  echo "❌ Không thể tạo Secret mysql-secret."
  exit 1
}

# Xóa file tạm
rm mysql-secret.yaml

# Kiểm tra Secret
echo "🔍 Kiểm tra Secret mysql-secret..."
kubectl get secret mysql-secret -o yaml || {
  echo "❌ Không thể lấy thông tin Secret mysql-secret."
  exit 1
}

echo "✅ Secret mysql-secret đã được tạo."

# 4. Kiểm tra khả năng kéo Docker image từ Docker Hub
echo "📦 4. Kiểm tra khả năng kéo Docker image từ Docker Hub..."
docker pull buithienboo/qlbandoannhanh-php-app:1.1 || {
    echo "❌ Không thể kéo image buithienboo/qlbandoannhanh-php-app:1.1 từ Docker Hub."
    echo "🔍 Vui lòng kiểm tra kết nối mạng hoặc xác nhận image tồn tại trên Docker Hub."
    exit 1
}
echo "✅ Đã kéo thành công image buithienboo/qlbandoannhanh-php-app:1.1"

# 5. Kiểm tra nội dung image
echo "🔍 5. Kiểm tra nội dung image buithienboo/qlbandoannhanh-php-app:1.1..."
docker run --rm -it buithienboo/qlbandoannhanh-php-app:1.1 bash -c "ls -l /var/www/html/index.php" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ File index.php tồn tại trong image tại /var/www/html/"
else
    echo "❌ File index.php không tồn tại trong image tại /var/www/html/"
    echo "🔍 Nội dung thư mục /var/www/html trong image:"
    docker run --rm -it buithienboo/qlbandoannhanh-php-app:1.1 bash -c "ls -la /var/www/html/"
    exit 1
fi

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

# 6. Tạo ConfigMap cho khởi tạo MySQL từ file trong image Docker Hub
echo "📦 6. Tạo ConfigMap cho khởi tạo MySQL từ file trong image..."
echo "🔍 Trích xuất file qlbandoannhanh.sql từ image buithienboo/qlbandoannhanh-php-app:1.1..."

# Tạo thư mục tạm để lưu file .sql
temp_dir=$(mktemp -d)
sql_file_path="$temp_dir/qlbandoannhanh.sql"

# Trích xuất file .sql từ image
docker run --rm buithienboo/qlbandoannhanh-php-app:1.1 cat /var/www/html/database/qlbandoannhanh.sql > "$sql_file_path" || {
    echo "❌ Không thể trích xuất file qlbandoannhanh.sql từ image."
    rm -rf "$temp_dir"
    exit 1
}

# Kiểm tra file .sql đã trích xuất
if [ -f "$sql_file_path" ]; then
    echo "✅ File qlbandoannhanh.sql đã được trích xuất thành công tại $sql_file_path"
else
    echo "❌ File qlbandoannhanh.sql không được trích xuất."
    rm -rf "$temp_dir"
    exit 1
fi

# Xóa ConfigMap cũ nếu tồn tại
kubectl delete configmap mysql-init --ignore-not-found || {
    echo "⚠️ Không thể xóa ConfigMap mysql-init cũ, nhưng tiếp tục..."
}

# Tạo ConfigMap từ file .sql đã trích xuất
kubectl create configmap mysql-init --from-file=qlbandoannhanh.sql="$sql_file_path" || {
    echo "❌ Không thể tạo ConfigMap mysql-init."
    rm -rf "$temp_dir"
    exit 1
}

# Xóa thư mục tạm
rm -rf "$temp_dir"
echo "✅ Đã xóa file tạm và thư mục $temp_dir"

# Kiểm tra ConfigMap vừa tạo
echo "🔍 Kiểm tra ConfigMap mysql-init..."
kubectl get configmap mysql-init > /dev/null 2>&1 || {
    echo "❌ ConfigMap mysql-init không được tạo thành công."
    kubectl describe configmap mysql-init
    exit 1
}
echo "✅ ConfigMap mysql-init đã được tạo thành công."

# Bước 7: Tạo ConfigMap cho cấu hình MySQL (tối ưu hóa) ,,
echo "🔧 7. Tạo ConfigMap cho cấu hình MySQL..."
if kubectl get configmap mysql-config -n default > /dev/null 2>&1; then
  if [ "$FORCE_RECREATE" = "true" ]; then
    echo "⚠️ ConfigMap mysql-config đã tồn tại, xóa và tạo lại..."
    kubectl delete configmap mysql-config -n default
  else
    echo "✅ ConfigMap mysql-config đã tồn tại, bỏ qua bước tạo."
  fi
fi

if ! kubectl get configmap mysql-config -n default > /dev/null 2>&1; then
  cat > mysql-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  my.cnf: |
    [mysqld]
    # Tối ưu hóa InnoDB để khởi động nhanh hơn
    innodb_buffer_pool_size=512M
    innodb_log_file_size=128M
    innodb_doublewrite=0  # Tắt doublewrite buffer (chỉ dùng trong môi trường phát triển)
    [client]
    # default-character-set=utf8mb4
    [mysql]
    # default-character-set=utf8mb4
EOF
  kubectl apply -f mysql-config.yaml || {
    echo "❌ Không thể tạo ConfigMap mysql-config."
    exit 1
  }
  echo "✅ ConfigMap mysql-config đã được tạo."
fi

# Xóa và tạo lại PersistentVolumeClaim để làm sạch dữ liệu
echo "🔧 Xóa và tạo lại PersistentVolumeClaim mysql-pvc..."
if kubectl get pvc mysql-pvc -n default > /dev/null 2>&1; then
  echo "⚠️ PVC mysql-pvc đã tồn tại, xóa và tạo lại..."
  kubectl delete pvc mysql-pvc -n default
fi

cat > mysql-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
kubectl apply -f mysql-pvc.yaml || {
  echo "❌ Không thể tạo PVC mysql-pvc."
  exit 1
}
echo "✅ PVC mysql-pvc đã được tạo."

# Bước 8: Tạo MySQL Deployment (tăng tài nguyên)
# Bước 8: Tạo MySQL Deployment
echo "🛢️ 8. Tạo MySQL Deployment..."
if kubectl get deployment mysql -n default > /dev/null 2>&1; then
  if [ "$FORCE_RECREATE" = "true" ]; then
    echo "⚠️ Deployment mysql đã tồn tại, xóa và tạo lại..."
    kubectl delete deployment mysql -n default
  else
    echo "✅ Deployment mysql đã tồn tại, bỏ qua bước tạo."
  fi
fi

if ! kubectl get deployment mysql -n default > /dev/null 2>&1; then
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
            memory: "512Mi"  # Reduced memory request
            cpu: "500m"      # Reduced CPU request
          limits:
            memory: "1Gi"    # Reduced memory limit
            cpu: "1"         # Reduced CPU limit
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
        - name: mysql-initdb
          mountPath: /docker-entrypoint-initdb.d
        - name: mysql-config
          mountPath: /etc/mysql/conf.d
        startupProbe:
          tcpSocket:
            port: 3306
          initialDelaySeconds: 30
          periodSeconds: 10
          failureThreshold: 30  # Allow up to 5 minutes for startup
        livenessProbe:
          tcpSocket:
            port: 3306
          initialDelaySeconds: 120  # Increased delay
          periodSeconds: 10
          failureThreshold: 5
        readinessProbe:
          tcpSocket:
            port: 3306
          initialDelaySeconds: 120  # Increased delay
          periodSeconds: 10
          failureThreshold: 5
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pvc
      - name: mysql-initdb
        configMap:
          name: mysql-init
      - name: mysql-config
        configMap:
          name: mysql-config
EOF
  kubectl apply -f mysql-deployment.yaml || {
    echo "❌ Không thể tạo Deployment mysql."
    exit 1
  }
  echo "✅ Deployment mysql đã được tạo."
fi
# Bước 9: Tạo MySQL Service
echo "🔄 9. Tạo MySQL Service..."
if kubectl get service mysql-service -n default > /dev/null 2>&1; then
  if [ "$FORCE_RECREATE" = "true" ]; then
    echo "⚠️ Service mysql-service đã tồn tại, xóa và tạo lại..."
    kubectl delete service mysql-service -n default
  else
    echo "✅ Service mysql-service đã tồn tại, bỏ qua bước tạo."
  fi
fi

if ! kubectl get service mysql-service -n default > /dev/null 2>&1; then
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
  kubectl apply -f mysql-service.yaml || {
    echo "❌ Không thể tạo Service mysql-service."
    exit 1
  }
  echo "✅ Service mysql-service đã được tạo."
fi

# Bước 10: Tạo ConfigMap cho cấu hình Apache
echo "🔧 10. Tạo ConfigMap cho cấu hình Apache..."
if kubectl get configmap apache-config -n default > /dev/null 2>&1; then
  if [ "$FORCE_RECREATE" = "true" ]; then
    echo "⚠️ ConfigMap apache-config đã tồn tại, xóa và tạo lại..."
    kubectl delete configmap apache-config -n default
  else
    echo "✅ ConfigMap apache-config đã tồn tại, bỏ qua bước tạo."
  fi
fi

if ! kubectl get configmap apache-config -n default > /dev/null 2>&1; then
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
  kubectl apply -f apache-config.yaml || {
    echo "❌ Không thể tạo ConfigMap apache-config."
    exit 1
  }
  echo "✅ ConfigMap apache-config đã được tạo."
fi
# 10.5. Tạo ConfigMap cho MySQL từ file trong image Docker
echo "📜 10.5 Tạo ConfigMap mysql-init để khởi tạo dữ liệu MySQL từ image Docker..."

# Kiểm tra Docker đã được cài đặt chưa
if ! command -v docker &> /dev/null; then
    echo "❌ Docker không được cài đặt. Vui lòng cài đặt Docker để tiếp tục."
    exit 1
fi

# Kiểm tra xem image đã tồn tại cục bộ chưa
echo "🔍 Kiểm tra image buithienboo/qlbandoannhanh-php-app:1.1 cục bộ..."
if docker image inspect buithienboo/qlbandoannhanh-php-app:1.1 > /dev/null 2>&1; then
    echo "✅ Image buithienboo/qlbandoannhanh-php-app:1.1 đã tồn tại cục bộ."
else
    # Tải image từ Docker Hub nếu chưa có
    echo "🔍 Tải image buithienboo/qlbandoannhanh-php-app:1.1 từ Docker Hub..."
    docker pull buithienboo/qlbandoannhanh-php-app:1.1 || {
        echo "❌ Không thể tải image buithienboo/qlbandoannhanh-php-app:1.1."
        exit 1
    }
fi

# Kiểm tra và xóa container temp-php-container nếu đã tồn tại
echo "🔍 Kiểm tra container temp-php-container..."
if docker ps -a --filter "name=temp-php-container" --format '{{.ID}}' | grep -q .; then
    echo "⚠️ Container temp-php-container đã tồn tại, đang xóa..."
    docker stop temp-php-container > /dev/null 2>&1 || {
        echo "⚠️ Không thể dừng container temp-php-container, nhưng tiếp tục..."
    }
    docker rm temp-php-container > /dev/null 2>&1 || {
        echo "❌ Không thể xóa container temp-php-container."
        exit 1
    }
fi

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
    docker stop temp-php-container > /dev/null 2>&1 || true
    exit 1
}

# Dừng container
echo "🔍 Dừng container tạm thời..."
docker stop temp-php-container > /dev/null 2>&1 || {
    echo "⚠️ Không thể dừng container temp-php-container, nhưng tiếp tục..."
}

# Tạo hoặc ghi đè ConfigMap
echo "📜 Tạo hoặc cập nhật ConfigMap mysql-init từ file copy..."
if [ -f "/tmp/qlbandoannhanh.sql" ]; then
    # Xóa ConfigMap cũ nếu tồn tại
    kubectl delete configmap mysql-init --ignore-not-found || {
        echo "⚠️ Không thể xóa ConfigMap mysql-init cũ, nhưng tiếp tục..."
    }
    # Tạo ConfigMap mới
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
# Sau khi tạo ConfigMap mysql-init ở bước 10.5
echo "🔄 Khởi động lại pod MySQL để áp dụng ConfigMap mới..."
kubectl delete pod -l app=mysql -n default || {
    echo "⚠️ Không thể khởi động lại pod MySQL, nhưng tiếp tục..."
}

# 11. Tạo ConfigMap cho PHP
echo "📜 11 Tạo ConfigMap cho PHP..."
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
kubectl get pods

echo "✅ ConfigMap php-config đã được tạo thành công."

#!/bin/bash

# 12. Tạo deployment PHP
chmod +x ./k8s/deploy_php_step_12_1.sh
chmod +x ./k8s/deploy_php_step_12_2.sh
chmod +x ./k8s/deploy_php_step_12_5.sh
chmod +x ./k8s/deploy_php_step_12_6.sh
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
./k8s/deploy_php_step_16_1.sh
./k8s/deploy_php_step_16_2.sh
./k8s/deploy_php_step_16_3.sh
./k8s/deploy_php_step_16_4.sh

echo "✅ Website PHP hoạt động bình thường."

# 17. Kiểm tra URL truy cập

# ./k8s/deploy_php_step_17.sh

#!/bin/bash

set -e

echo "🚀 [18] Thêm tên miền vào /etc/hosts để truy cập dịch vụ PHP..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt 2>/dev/null || echo "")
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kiểm tra trạng thái pod
echo "🔍 Kiểm tra trạng thái pod PHP..."
php_status=$(kubectl get pod "$php_pod" -o jsonpath='{.status.phase}' -n default 2>/dev/null || echo "NotRunning")
php_ready=$(kubectl get pod "$php_pod" -o jsonpath='{.status.containerStatuses[0].ready}' -n default 2>/dev/null || echo "false")
if [ "$php_status" != "Running" ] || [ "$php_ready" != "true" ]; then
  echo "❌ Pod PHP ($php_pod) không sẵn sàng."
  kubectl describe pod "$php_pod" -n default
  kubectl logs "$php_pod" -n default 2>/dev/null || echo "⚠️ Không thể lấy log."
  exit 1
fi

# Kiểm tra dịch vụ php-service
echo "🔍 Kiểm tra dịch vụ php-service..."
kubectl get service php-service -n default >/dev/null 2>&1 || {
  echo "❌ Dịch vụ php-service không tồn tại. Vui lòng chạy bước 17 trước."
  exit 1
}

# Đảm bảo Ingress controller đã bật
echo "🔍 Kiểm tra và bật Ingress controller..."
minikube addons enable ingress >/dev/null 2>&1
sleep 5

# Tạo Ingress
echo "🔍 Tạo Ingress cho PHP..."
kubectl delete ingress php-ingress -n default --ignore-not-found
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: php-ingress
  namespace: default
spec:
  rules:
  - host: php.local
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

# Kiểm tra minikube tunnel
echo "🔍 Kiểm tra minikube tunnel..."
if ! pgrep -f "minikube tunnel" > /dev/null; then
  echo "⚠️ minikube tunnel không chạy. Khởi động trong nền..."
  nohup minikube tunnel > tunnel.log 2>&1 &
  sleep 5
fi

# Lấy IP và thêm vào /etc/hosts
custom_domain="php.local"
minikube_ip=$(minikube ip)
echo "🔍 Thêm $custom_domain vào /etc/hosts..."
if sudo grep -q "$custom_domain" /etc/hosts; then
  sudo sed -i "/$custom_domain/d" /etc/hosts
fi
echo "$minikube_ip $custom_domain" | sudo tee -a /etc/hosts || {
  echo "❌ Không thể thêm vào /etc/hosts."
  exit 1
}

# Kiểm tra kết nối
echo "🔍 Kiểm tra kết nối đến $custom_domain..."
if curl --connect-timeout 5 "http://$custom_domain" >/dev/null 2>&1; then
  echo "✅ Kết nối đến http://$custom_domain thành công."
else
  echo "❌ Không thể truy cập http://$custom_domain."
  kubectl logs "$php_pod" -n default 2>/dev/null || echo "⚠️ Không thể lấy log."
  exit 1
fi

echo "✅ [18] Đã thêm tên miền $custom_domain vào /etc/hosts."
echo "🔗 Truy cập tại: http://$custom_domain"