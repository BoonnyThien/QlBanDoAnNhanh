#!/bin/bash

echo "🚀 Creating new PHP deployment..."

# Delete old deployment if it exists
kubectl delete deployment php-deployment --ignore-not-found

# Create new PHP deployment
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
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 2
          failureThreshold: 3
        volumeMounts:
        - name: php-config
          mountPath: /usr/local/etc/php/conf.d/custom.ini
          subPath: php.ini
        - name: php-db-config
          mountPath: /var/www/html/admin/config/config.php
          subPath: config.php
        - name: php-error-config
          mountPath: /usr/local/etc/php/conf.d/error.ini
          subPath: error.ini
      volumes:
      - name: php-config
        configMap:
          name: php-config
      - name: php-db-config
        configMap:
          name: php-db-config
      - name: php-error-config
        configMap:
          name: php-error-config
EOF

# Wait for pod to be created
echo "⏳ Waiting for PHP pod to be created..."
sleep 10

# Get the name of the pod
php_pod=$(kubectl get pods -l app=php -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$php_pod" ]; then
  echo "✅ PHP pod created: $php_pod"
  echo "$php_pod" > /tmp/php_pod_name.txt
else
  echo "❌ Failed to create PHP pod."
  kubectl get pods
  exit 1
fi

echo "✅ PHP deployment fixed and created" 