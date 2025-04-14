#!/bin/bash

# Xóa tất cả các tài nguyên cũ
echo "Xóa tất cả các tài nguyên cũ..."
kubectl delete deployment php-app --force --grace-period=0
kubectl delete statefulset mysql --force --grace-period=0
kubectl delete service mysql-service --force --grace-period=0
kubectl delete service php-service --force --grace-period=0
kubectl delete pvc --all --force --grace-period=0
kubectl delete pv --all --force --grace-period=0
kubectl delete configmap --all --force --grace-period=0
kubectl delete secret --all --force --grace-period=0

# Đợi và kiểm tra tài nguyên đã xóa
echo "Đợi tài nguyên được xóa hoàn toàn..."
for i in {1..30}; do
    echo "Kiểm tra lần $i..."
    
    # Kiểm tra từng loại tài nguyên
    echo "Kiểm tra Deployments:"
    kubectl get deployments -o wide
    echo "Kiểm tra StatefulSets:"
    kubectl get statefulsets -o wide
    echo "Kiểm tra Services:"
    kubectl get services -o wide
    echo "Kiểm tra PVCs:"
    kubectl get pvc -o wide
    echo "Kiểm tra PVs:"
    kubectl get pv -o wide
    echo "Kiểm tra ConfigMaps:"
    kubectl get configmaps -o wide
    echo "Kiểm tra Secrets:"
    kubectl get secrets -o wide
    
    # Kiểm tra pods và trạng thái của chúng
    echo "Kiểm tra Pods và trạng thái:"
    kubectl get pods -o wide
    echo "Kiểm tra Events gần đây:"
    kubectl get events --sort-by='.lastTimestamp' | tail -n 10
    
    # Kiểm tra xem còn tài nguyên nào không
    if ! kubectl get deployment php-app 2>/dev/null && \
       ! kubectl get statefulset mysql 2>/dev/null && \
       ! kubectl get service mysql-service 2>/dev/null && \
       ! kubectl get service php-service 2>/dev/null && \
       ! kubectl get pvc 2>/dev/null && \
       ! kubectl get pv 2>/dev/null && \
       ! kubectl get configmap 2>/dev/null && \
       ! kubectl get secret 2>/dev/null; then
        echo "Tất cả tài nguyên đã được xóa."
        break
    fi
    
    # Nếu vẫn còn pods, hiển thị chi tiết về chúng
    if [ $(kubectl get pods -o name | wc -l) -gt 0 ]; then
        echo "Vẫn còn pods đang chạy. Chi tiết:"
        for pod in $(kubectl get pods -o name); do
            echo "Pod: $pod"
            kubectl describe $pod | grep -A 10 "Events:"
        done
    fi
    
    echo "Vẫn còn tài nguyên tồn tại, đợi thêm..."
    sleep 5
done

# Kiểm tra pods đang chạy
echo "Kiểm tra pods đang chạy..."
kubectl get pods -o wide
if [ $(kubectl get pods -o name | wc -l) -gt 0 ]; then
    echo "Vẫn còn pods đang chạy, xóa chúng..."
    kubectl delete pods --all --force --grace-period=0
    sleep 10
fi

# Tạo StorageClass
echo "Tạo StorageClass..."
cat > k8s/storageclass.yaml << EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: manual
provisioner: k8s.io/minikube-hostpath
EOF

# Tạo Secret cho MySQL
echo "Tạo Secret cho MySQL..."
cat > k8s/secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
stringData:
  username: root
  password: password
  root-password: password
EOF

# Tạo ConfigMap cho Apache
echo "Tạo ConfigMap cho Apache..."
cat > k8s/apache-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: apache-config
data:
  000-default.conf: |
    <VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
        <Directory /var/www/html>
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
    </VirtualHost>
EOF

# Tạo PersistentVolume cho MySQL
echo "Tạo PersistentVolume cho MySQL..."
cat > k8s/mysql-pv.yaml << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data/mysql
EOF

# Tạo PersistentVolumeClaim cho MySQL
echo "Tạo PersistentVolumeClaim cho MySQL..."
cat > k8s/mysql-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: manual
EOF

# Tạo PersistentVolume cho PHP
echo "Tạo PersistentVolume cho PHP..."
cat > k8s/php-pv.yaml << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: php-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data/php
EOF

# Tạo PersistentVolumeClaim cho PHP
echo "Tạo PersistentVolumeClaim cho PHP..."
cat > k8s/php-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: php-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: manual
EOF

# Áp dụng các cấu hình mới
echo "Áp dụng các cấu hình mới..."
kubectl apply -f k8s/storageclass.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/apache-config.yaml
kubectl apply -f k8s/mysql-pv.yaml
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/php-pv.yaml
kubectl apply -f k8s/php-pvc.yaml

# Đợi PVCs được bound
echo "Đợi PVCs được bound..."
kubectl wait --for=condition=bound pvc/mysql-pvc --timeout=60s
kubectl wait --for=condition=bound pvc/php-pvc --timeout=60s

# Tạo thư mục trong Minikube
echo "Tạo thư mục trong Minikube..."
minikube ssh "sudo mkdir -p /mnt/data/mysql /mnt/data/php"
minikube ssh "sudo chmod -R 777 /mnt/data"

# Copy PHP code vào Minikube
echo "Copy PHP code vào Minikube..."
echo "1. Nén thư mục PHP code..."
tar -czvf phpCode.tar.gz phpCode --exclude='*.git*' --exclude='*.svn*' 2>&1 | tee copy_errors.log
if [ $? -ne 0 ]; then
    echo "Lỗi khi nén thư mục:"
    cat copy_errors.log
    exit 1
fi

echo "2. Copy file nén vào Minikube..."
minikube cp phpCode.tar.gz /mnt/data/phpCode.tar.gz 2>&1 | tee -a copy_errors.log
if [ $? -ne 0 ]; then
    echo "Lỗi khi copy file nén:"
    cat copy_errors.log
    exit 1
fi

echo "3. Giải nén trong Minikube..."
minikube ssh "sudo rm -rf /mnt/data/php/* && sudo mkdir -p /mnt/data/php && sudo tar -xzvf /mnt/data/phpCode.tar.gz -C /mnt/data/php --strip-components=1" 2>&1 | tee -a copy_errors.log
if [ $? -ne 0 ]; then
    echo "Lỗi khi giải nén:"
    cat copy_errors.log
    exit 1
fi

echo "4. Xóa file nén tạm..."
rm phpCode.tar.gz
minikube ssh "sudo rm /mnt/data/phpCode.tar.gz"

echo "5. Kiểm tra quyền truy cập..."
minikube ssh "sudo chown -R 33:33 /mnt/data/php && sudo chmod -R 755 /mnt/data/php" 2>&1 | tee -a copy_errors.log
if [ $? -ne 0 ]; then
    echo "Lỗi khi cấp quyền truy cập:"
    cat copy_errors.log
    exit 1
fi

# Áp dụng lại cấu hình
echo "Áp dụng lại cấu hình..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service-php.yaml
kubectl apply -f k8s/service-mysql.yaml
kubectl apply -f k8s/mysql-statefulset.yaml

# Kiểm tra trạng thái
echo "Kiểm tra trạng thái..."
kubectl get storageclass
kubectl get secret mysql-secret
kubectl get configmap apache-config
kubectl get pv
kubectl get pvc
kubectl get pods -o wide

# Đợi pods khởi động
echo "Đợi pods khởi động..."
echo "Kiểm tra trạng thái pods..."
kubectl get pods -o wide

echo "Kiểm tra logs của pods..."
for pod in $(kubectl get pods -l app=php-app -o name); do
    echo "Logs của $pod:"
    kubectl logs $pod
done

echo "Kiểm tra events..."
kubectl get events --sort-by='.lastTimestamp'

echo "Đợi pods khởi động..."
kubectl wait --for=condition=ready pod -l app=php-app --timeout=300s || {
    echo "Pods không khởi động được. Kiểm tra chi tiết:"
    kubectl describe pods -l app=php-app
    exit 1
}

kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s || {
    echo "MySQL pod không khởi động được. Kiểm tra chi tiết:"
    kubectl describe pods -l app=mysql
    exit 1
}

# Kiểm tra trạng thái cuối cùng
echo "Kiểm tra trạng thái cuối cùng..."
kubectl get pods -o wide
kubectl get pv
kubectl get pvc
kubectl get services

echo "Hoàn tất!" 