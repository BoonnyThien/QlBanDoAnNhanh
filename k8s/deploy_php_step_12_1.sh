# Bước 12.1: Tạo deployment PHP và các tài nguyên liên quan
echo "🚀 [12.1] Tạo deployment PHP và các tài nguyên liên quan..."

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

# Tạo và áp dụng deployment PHP
echo "🚀 Tạo PHP Deployment..."
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
      initContainers:
      - name: wait-for-mysql
        image: busybox:1.36
        command: ['sh', '-c', 'until nc -z mysql-service 3306; do echo "Waiting for MySQL..."; sleep 5; done;']
      containers:
      - name: php
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
            path: /index.php
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
  echo "❌ Không thể áp dụng deployment PHP."
  exit 1
}
rm -f php-deployment.yaml

# Đợi và kiểm tra trạng thái PHP pod với vòng lặp
echo "🔍 Đợi và kiểm tra trạng thái PHP pod..."
max_attempts=60  # Tối đa 600 giây (10 phút)
attempt=1
while [ $attempt -le $max_attempts ]; do
  echo "🔍 Kiểm tra trạng thái PHP pod (lần $attempt/$max_attempts)..."
  kubectl get pods
  php_pod=$(kubectl get pods -l app=php -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
  
  if [ -z "$php_pod" ]; then
    echo "⚠️ PHP pod chưa được tạo."
    sleep 10
    attempt=$((attempt + 1))
    continue
  fi
  
  php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
  php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
  
  if [ "$php_status" = "CrashLoopBackOff" ] || [ "$php_status" = "Error" ]; then
    echo "❌ PHP pod gặp lỗi nghiêm trọng (Trạng thái: $php_status)."
    echo "📝 Chi tiết pod:"
    kubectl describe pod $php_pod
    echo "📝 Log pod:"
    kubectl logs $php_pod 2>/dev/null || echo "Không có log (pod chưa chạy)."
    exit 1
  fi
  
  if [ "$php_status" != "Running" ]; then
    echo "⚠️ PHP pod chưa ở trạng thái Running (Trạng thái: $php_status)."
  elif [ "$php_ready" != "true" ]; then
    echo "⚠️ PHP pod chưa sẵn sàng (Trạng thái: $php_status, Ready: $php_ready)."
  else
    echo "✅ PHP pod đã sẵn sàng!"
    break
  fi
  
  if [ $attempt -eq $max_attempts ]; then
    echo "❌ Hết thời gian chờ, PHP pod không sẵn sàng:"
    echo "📝 Chi tiết pod:"
    kubectl describe pod $php_pod
    echo "📝 Log pod:"
    kubectl logs $php_pod 2>/dev/null || echo "Không có log (pod chưa chạy)."
    exit 1
  fi
  
  sleep 10
  attempt=$((attempt + 1))
done