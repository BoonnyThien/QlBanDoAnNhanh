# Bước 12.1: Tạo deployment PHP (Frontend và Admin) và các tài nguyên liên quan
echo "🚀 [12.1] Tạo deployment PHP (Frontend và Admin) và các tài nguyên liên quan..."

# Kiểm tra ConfigMap php-config
echo "🔍 Kiểm tra ConfigMap php-config..."
kubectl get configmap php-config -n default > /dev/null 2>&1 || {
  echo "❌ ConfigMap php-config không tồn tại. Vui lòng tạo ConfigMap trước."
  exit 1
}

# Kiểm tra Secret mysql-secret
echo "🔐 Kiểm tra Secret mysql-secret..."
if kubectl get secret mysql-secret -n default > /dev/null 2>&1; then
  echo "✅ Secret mysql-secret đã tồn tại."
else
  echo "🔐 Tạo Secret mysql-secret..."
  kubectl create secret generic mysql-secret \
    --from-literal=root-password='your-root-password' \
    --from-literal=username='app_user' \
    --from-literal=user-password='userpass' -n default || {
      echo "❌ Không thể tạo Secret mysql-secret."
      exit 1
    }
fi

# Kiểm tra ConfigMap mysql-init
echo "🔍 Kiểm tra ConfigMap mysql-init..."
kubectl get configmap mysql-init -n default > /dev/null 2>&1 || {
  echo "❌ ConfigMap mysql-init không tồn tại. Vui lòng tạo ConfigMap trước."
  exit 1
}

# Kiểm tra và tạo ConfigMap php-error-config nếu chưa tồn tại
echo "🔍 Kiểm tra ConfigMap php-error-config..."
if kubectl get configmap php-error-config -n default > /dev/null 2>&1; then
  echo "✅ ConfigMap php-error-config đã tồn tại."
else
  echo "📜 Tạo ConfigMap php-error-config..."
  cat > php-error-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: php-error-config
  namespace: default
data:
  error.ini: |
    display_errors = On
    display_startup_errors = On
    error_reporting = E_ALL
    log_errors = On
    error_log = /var/log/php_errors.log
EOF
  kubectl apply -f php-error-config.yaml || {
    echo "❌ Không thể tạo ConfigMap php-error-config."
    exit 1
  }
  rm -f php-error-config.yaml
fi

# Kiểm tra ConfigMap apache-config
echo "🔍 Kiểm tra ConfigMap apache-config..."
kubectl get configmap apache-config -n default > /dev/null 2>&1 || {
  echo "❌ ConfigMap apache-config không tồn tại. Vui lòng tạo ConfigMap trước."
  exit 1
}

# Tạo và áp dụng deployment PHP Frontend (User)
echo "🚀 Tạo PHP Frontend (User) Deployment..."
cat > php-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-deployment
  labels:
    app: php-app
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
      initContainers:
      - name: wait-for-mysql
        image: busybox:1.36
        command: ['sh', '-c', 'until nc -z mysql-service 3306; do echo "Waiting for MySQL..."; sleep 5; done;']
      containers:
      - name: php-app
        image: buithienboo/qlbandoannhanh-php-app:1.1
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /user/index.php  # Truy cập đúng mã nguồn user
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 10
        volumeMounts:
        - name: php-error-config
          mountPath: /usr/local/etc/php/conf.d/error.ini
          subPath: error.ini
        - name: apache-config
          mountPath: /etc/apache2/conf-enabled/apache.conf
          subPath: apache.conf
      volumes:
      - name: php-error-config
        configMap:
          name: php-error-config
      - name: apache-config
        configMap:
          name: apache-config
EOF
kubectl apply -f php-deployment.yaml -n default || {
  echo "❌ Không thể áp dụng deployment PHP Frontend (User)."
  exit 1
}
rm -f php-deployment.yaml

# Tạo và áp dụng deployment PHP Admin
echo "🚀 Tạo PHP Admin Deployment..."
cat > php-admin-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-admin-deployment
  labels:
    app: php-admin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-admin
  template:
    metadata:
      labels:
        app: php-admin
    spec:
      initContainers:
      - name: wait-for-mysql
        image: busybox:1.36
        command: ['sh', '-c', 'until nc -z mysql-service 3306; do echo "Waiting for MySQL..."; sleep 5; done;']
      containers:
      - name: php-admin
        image: buithienboo/qlbandoannhanh-php-app:1.1
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /admin/index.php  # Truy cập đúng mã nguồn admin
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 10
        volumeMounts:
        - name: php-error-config
          mountPath: /usr/local/etc/php/conf.d/error.ini
          subPath: error.ini
        - name: apache-config
          mountPath: /etc/apache2/conf-enabled/apache.conf
          subPath: apache.conf
      volumes:
      - name: php-error-config
        configMap:
          name: php-error-config
      - name: apache-config
        configMap:
          name: apache-config
EOF
kubectl apply -f php-admin-deployment.yaml -n default || {
  echo "❌ Không thể áp dụng deployment PHP Admin."
  exit 1
}
rm -f php-admin-deployment.yaml

# Tạo Service cho PHP Frontend (User)
echo "🚀 Tạo Service cho PHP Frontend (User)..."
cat > php-app-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: php-app-service
  namespace: default
spec:
  selector:
    app: php-app
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080  # Port truy cập từ bên ngoài
  type: NodePort
EOF
kubectl apply -f php-app-service.yaml -n default || {
  echo "❌ Không thể áp dụng Service PHP Frontend (User)."
  exit 1
}
rm -f php-app-service.yaml

# Tạo Service cho PHP Admin
echo "🚀 Tạo Service cho PHP Admin..."
cat > php-admin-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: php-admin-service
  namespace: default
spec:
  selector:
    app: php-admin
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30081  # Port truy cập từ bên ngoài
  type: NodePort
EOF
kubectl apply -f php-admin-service.yaml -n default || {
  echo "❌ Không thể áp dụng Service PHP Admin."
  exit 1
}
rm -f php-admin-service.yaml

