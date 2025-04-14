#!/bin/bash

echo "🔧 Script khắc phục toàn diện cho ứng dụng Kubernetes Đồ Ăn Nhanh"
echo "================================================================="

# 1. Khởi động lại Minikube với đủ tài nguyên
echo "🚀 Khởi động lại Minikube với tài nguyên cần thiết..."
minikube stop
minikube delete
minikube start --driver=docker --memory=3072 --cpus=2 --disk-size=20g

echo "⏳ Đợi minikube khởi động hoàn tất..."
sleep 10

# Kiểm tra Minikube
echo "✅ Kiểm tra trạng thái Minikube:"
minikube status

# 2. Xóa mọi tài nguyên cũ
echo "🧹 Dọn dẹp tài nguyên cũ..."
kubectl delete all --all --grace-period=0 --force
kubectl delete pvc,pv --all --grace-period=0 --force
kubectl delete configmap,secret --all --grace-period=0 --force --ignore-not-found=true
kubectl delete job --all --grace-period=0 --force --ignore-not-found=true

echo "⏳ Đợi tài nguyên xóa hoàn tất..."
sleep 5

# 3. Tạo Secret
echo "🔒 Tạo MySQL Secret..."
kubectl create secret generic mysql-secret \
  --from-literal=root-password=rootpassword \
  --from-literal=user-password=userpassword \
  --from-literal=username=app_user

# 4. Tạo ConfigMap cho code PHP
echo "📄 Tạo ConfigMap cho code PHP..."
cat > simplified-php-code.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: php-code
data:
  index.php: |
    <?php
    echo "<h1>Ứng dụng Đồ Ăn Nhanh</h1>";
    echo "<p>Trạng thái kết nối:</p>";
    
    \$host = 'mysql-service';
    \$dbname = 'qlbandoannhanh';
    \$user = 'app_user';
    \$pass = 'userpassword';
    
    try {
        \$conn = new PDO("mysql:host=\$host;dbname=\$dbname", \$user, \$pass);
        \$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        echo "<p style='color:green'>✅ Kết nối MySQL thành công!</p>";
        
        // Thử truy vấn dữ liệu
        \$stmt = \$conn->query("SELECT * FROM categories LIMIT 5");
        echo "<h3>Danh mục sản phẩm:</h3>";
        echo "<ul>";
        while (\$row = \$stmt->fetch(PDO::FETCH_ASSOC)) {
            echo "<li>" . \$row['name'] . ": " . \$row['description'] . "</li>";
        }
        echo "</ul>";
    } catch(PDOException \$e) {
        echo "<p style='color:red'>❌ Lỗi kết nối MySQL: " . \$e->getMessage() . "</p>";
    }
    ?>
    
    <h2>Thông tin hệ thống:</h2>
    <?php
    echo "<p>Server IP: " . \$_SERVER['SERVER_ADDR'] . "</p>";
    echo "<p>PHP Version: " . phpversion() . "</p>";
    ?>
EOF

kubectl apply -f simplified-php-code.yaml

# 5. Tạo ConfigMap cho MySQL khởi tạo
echo "📦 Tạo ConfigMap cho khởi tạo MySQL..."
cat > mysql-init.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-init
data:
  init.sql: |
    CREATE DATABASE IF NOT EXISTS qlbandoannhanh;
    USE qlbandoannhanh;
    
    CREATE TABLE IF NOT EXISTS categories (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      description TEXT
    );
    
    CREATE TABLE IF NOT EXISTS products (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      description TEXT,
      price DECIMAL(10,2) NOT NULL,
      category_id INT,
      FOREIGN KEY (category_id) REFERENCES categories(id)
    );
    
    -- Thêm dữ liệu mẫu
    INSERT IGNORE INTO categories (name, description) VALUES
    ('Burger', 'Các loại bánh burger thơm ngon'),
    ('Pizza', 'Pizza đa dạng hương vị'),
    ('Nước uống', 'Đồ uống giải khát');
    
    INSERT IGNORE INTO products (name, description, price, category_id) VALUES
    ('Burger Phô Mai', 'Burger với lớp phô mai béo ngậy', 55000, 1),
    ('Pizza Hải Sản', 'Pizza hải sản tươi ngon', 95000, 2),
    ('Coca Cola', 'Nước giải khát có gas', 15000, 3);
EOF

kubectl apply -f mysql-init.yaml

# 6. Tạo MySQL Deployment (Thay vì StatefulSet để đơn giản hóa)
echo "🛢️ Tạo MySQL Deployment đơn giản..."
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
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi" 
            cpu: "500m"
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
        - name: mysql-initdb
          mountPath: /docker-entrypoint-initdb.d
      volumes:
      - name: mysql-storage
        emptyDir: {}
      - name: mysql-initdb
        configMap:
          name: mysql-init
EOF

kubectl apply -f mysql-deployment.yaml

# 7. Tạo MySQL Service
echo "🔄 Tạo MySQL Service..."
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

# 8. Tạo PHP Deployment đơn giản với image có sẵn PDO
echo "🚀 Tạo PHP Deployment..."
cat > php-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-app
  template:
    metadata:
      labels:
        app: php-app
    spec:
      containers:
      - name: php-app
        image: php:8.0-apache
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        volumeMounts:
        - name: php-code-volume
          mountPath: /var/www/html
        command: ["/bin/sh", "-c"]
        args:
        - |
          apt-get update && \
          apt-get install -y default-mysql-client libpq-dev && \
          docker-php-ext-install pdo pdo_mysql && \
          cp /code-config/index.php /var/www/html/ && \
          chmod 644 /var/www/html/index.php && \
          apache2-foreground
      volumes:
      - name: php-code-volume
        configMap:
          name: php-code
EOF

kubectl apply -f php-deployment.yaml

# 9. Tạo PHP Service
echo "🌐 Tạo PHP Service (NodePort)..."
cat > php-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: php-service
spec:
  selector:
    app: php-app
  ports:
  - port: 80
    targetPort: 80
  type: NodePort
EOF

kubectl apply -f php-service.yaml

echo "⏳ Đợi các pod khởi động..."
sleep 30

echo "🔍 Kiểm tra trạng thái Pod..."
kubectl get pods

echo "🔍 Mô tả lỗi nếu có:"
for pod in $(kubectl get pods -o custom-columns=:metadata.name); do
  status=$(kubectl get pod $pod -o jsonpath='{.status.phase}')
  if [ "$status" != "Running" ]; then
    echo "📝 Chi tiết lỗi pod $pod:"
    kubectl describe pod $pod
    echo "📝 Log của pod $pod:"
    kubectl logs $pod
  fi
done

# Kiểm tra URL truy cập
echo "🔍 Thông tin truy cập dịch vụ:"
minikube service php-service --url

echo "================================================================="
echo "✅ Hoàn tất! Để truy cập ứng dụng PHP, chạy: minikube service php-service"
echo "👉 Hoặc truy cập URL đã hiển thị phía trên"
echo "================================================================="