#!/bin/bash
# setup_and_repair.sh

# 1. Kiểm tra trạng thái Minikube và khởi động lại nếu cần
echo "🚀 1.Kiểm tra và khởi động Minikube..."
minikube_status=$(minikube status | grep host | awk '{print $2}' 2>/dev/null || echo "NotRunning")
if [ "$minikube_status" != "Running" ]; then
    echo "Minikube không chạy, khởi động lại..."
    minikube stop 2>/dev/null || true
    minikube delete --purge 2>/dev/null || true
    minikube start --driver=docker --memory=4096 --cpus=4 --addons=ingress
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

# Bước 6: Tạo ConfigMap cho khởi tạo MySQL từ file trong image Docker Hub
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

# Bước 7: Tạo ConfigMap cho cấu hình MySQL
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
    innodb_buffer_pool_size=512M
    innodb_log_file_size=128M
    innodb_doublewrite=0
    character-set-server=utf8mb4
    collation-server=utf8mb4_unicode_ci
    [client]
    [mysql]
EOF
  kubectl apply -f mysql-config.yaml || {
    echo "❌ Không thể tạo ConfigMap mysql-config."
    exit 1
  }
  echo "✅ ConfigMap mysql-config đã được tạo."
fi

# Bước 8: Tạo PersistentVolumeClaim (PVC) cho MySQL
echo "🔧 8. Tạo PersistentVolumeClaim mysql-pvc..."
if kubectl get pvc mysql-pvc -n default > /dev/null 2>&1; then
  echo "⚠️ PVC mysql-pvc đã tồn tại, xóa và tạo lại..."
  kubectl delete pvc mysql-pvc -n default
fi
cat > mysql-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
  namespace: default
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
echo "⏳ Đợi PVC mysql-pvc sẵn sàng..."
max_attempts=12  # Chờ tối đa 120 giây (12 lần x 10 giây)
attempt=1
while [ $attempt -le $max_attempts ]; do
  pvc_status=$(kubectl get pvc mysql-pvc -n default -o jsonpath='{.status.phase}' 2>/dev/null || echo "Pending")
  if [ "$pvc_status" = "Bound" ]; then
    echo "✅ PVC mysql-pvc đã được bound."
    break
  fi
  echo "🔍 PVC mysql-pvc vẫn đang chờ (lần $attempt/$max_attempts)..."
  sleep 10
  attempt=$((attempt + 1))
  if [ $attempt -eq $max_attempts ]; then
    echo "❌ PVC mysql-pvc không được bound sau 120 giây."
    kubectl describe pvc mysql-pvc -n default
    exit 1
  fi
done
echo "✅ PVC mysql-pvc đã được tạo và bound."

# Bước 9: Tạo MySQL Deployment
echo "🛢️ 9. Tạo MySQL Deployment..."
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
        startupProbe:
          tcpSocket:
            port: 3306
          initialDelaySeconds: 30
          periodSeconds: 10
          failureThreshold: 30
        livenessProbe:
          tcpSocket:
            port: 3306
          initialDelaySeconds: 120
          periodSeconds: 10
          failureThreshold: 5
        readinessProbe:
          tcpSocket:
            port: 3306
          initialDelaySeconds: 120
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

# Bước 10: Tạo MySQL Service
echo "🔄 10. Tạo MySQL Service..."
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
find . -type f -name "*.sh" -exec sed -i 's/\r$//' {} +
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

chmod +x ./k8s/setup_and_repair1.sh
./k8s/setup_and_repair1.sh



