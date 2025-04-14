#!/bin/bash

# 12.1. Tạo deployment PHP và kiểm tra pod
echo "🚀 [12.1] Tạo deployment PHP..."

# Đảm bảo ConfigMap php-config đã được tạo
echo "🔍 Kiểm tra ConfigMap php-config..."
kubectl get configmap php-config > /dev/null 2>&1 || {
  echo "❌ ConfigMap php-config không tồn tại. Vui lòng tạo ConfigMap trước."
  exit 1
}

# Tạo deployment PHP với image buithienboo/qlbandoannhanh-php-app:1.1
cat <<EOF | kubectl apply -f -
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
          mountPath: /usr/local/etc/php/conf.d/
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

# Kiểm tra deployment PHP
echo "🔍 Kiểm tra deployment PHP..."
kubectl rollout status deployment/php-deployment --timeout=120s || {
  echo "❌ Deployment PHP không sẵn sàng."
  echo "🔍 Kiểm tra chi tiết deployment:"
  kubectl describe deployment php-deployment
  echo "🔍 Log của pod PHP:"
  kubectl logs -l app=php
  exit 1
}

# Kiểm tra pod PHP
echo "🔍 Kiểm tra pod PHP..."
max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
  echo "🔍 Kiểm tra pod PHP (lần $attempt/$max_attempts)..."
  php_pod=$(kubectl get pods -l app=php -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
  if [ -n "$php_pod" ]; then
    php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
    php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
    if [ "$php_status" = "Running" ] && [ "$php_ready" = "true" ]; then
      echo "✅ Pod PHP ($php_pod) đang chạy và sẵn sàng."
      break
    fi
  fi

  if [ $attempt -eq $max_attempts ]; then
    echo "❌ Không tìm thấy pod PHP hoặc pod không sẵn sàng."
    echo "🔍 Danh sách pod:"
    kubectl get pods -l app=php
    echo "🔍 Chi tiết deployment:"
    kubectl describe deployment php-deployment
    echo "🔍 Log của pod (nếu có):"
    kubectl logs -l app=php --all-containers
    exit 1
  fi

  sleep 5
  attempt=$((attempt + 1))
done

# Lưu tên pod vào file để sử dụng ở các bước sau
echo "$php_pod" > /tmp/php_pod_name.txt

echo "✅ [12.1] Tạo deployment PHP và kiểm tra pod hoàn tất."