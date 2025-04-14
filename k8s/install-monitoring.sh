#!/bin/bash

set -e

echo "📊 Setting up Kubernetes monitoring..."
echo "-------------------------------------"

# 1. Kiểm tra trạng thái Minikube và khởi động lại nếu cần
echo "🚀 Kiểm tra và khởi động Minikube..."
minikube_status=$(minikube status | grep host | awk '{print $2}' 2>/dev/null || echo "NotRunning")
if [ "$minikube_status" != "Running" ]; then
    echo "Minikube không chạy, khởi động lại..."
    minikube stop 2>/dev/null || true
    minikube delete --purge 2>/dev/null || true
    minikube start --driver=docker --memory=3072 --cpus=2 --addons=ingress
    # Đảm bảo quyền cho thư mục minikube
    [ -d ~/.minikube ] && chmod -R 755 ~/.minikube
else
    echo "Minikube đã chạy, tiếp tục thiết lập giám sát..."
fi

echo "⏳ Đợi Minikube khởi động hoàn tất..."
sleep 10
kubectl cluster-info

# 2. Cài đặt Prometheus Operator CRDs (bỏ CRD gây lỗi)
echo "🔧 Cài đặt Prometheus Operator CRDs..."
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
# Bỏ CRD prometheuses.monitoring.coreos.com do lỗi kích thước quá lớn
# kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.66.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml

echo "✅ Cài đặt Prometheus Operator CRDs hoàn tất!"

# 3. Tạo namespace monitoring nếu chưa tồn tại
echo "🔧 Tạo namespace monitoring..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# 4. Tạo ConfigMap cho Prometheus
echo "🔧 Tạo ConfigMap cho Prometheus..."
cat > k8s/prometheus-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    scrape_configs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: \$1:\$2
            target_label: __address__
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
          - role: node
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_node_label_(.+)
      - job_name: 'kubernetes-services'
        kubernetes_sd_configs:
          - role: service
        metrics_path: /metrics
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
            action: keep
            regex: true
EOF

kubectl apply -f k8s/prometheus-config.yaml
echo "✅ Prometheus ConfigMap tạo thành công"

# 5. Tạo Deployment cho Prometheus với tài nguyên thấp hơn
echo "🔧 Tạo Deployment cho Prometheus..."
cat > k8s/prometheus-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:v2.44.0
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config-volume
          mountPath: /etc/prometheus
        - name: prometheus-data
          mountPath: /prometheus
        args:
        - "--config.file=/etc/prometheus/prometheus.yml"
        - "--storage.tsdb.path=/prometheus"
        - "--web.console.libraries=/etc/prometheus/console_libraries"
        - "--web.console.templates=/etc/prometheus/consoles"
        - "--web.enable-lifecycle"
        - "--storage.tsdb.retention.time=6h"
        readinessProbe:
          httpGet:
            path: /-/ready
            port: 9090
          initialDelaySeconds: 30
          periodSeconds: 15
          timeoutSeconds: 10
        livenessProbe:
          httpGet:
            path: /-/healthy
            port: 9090
          initialDelaySeconds: 30
          periodSeconds: 15
          timeoutSeconds: 10
      volumes:
      - name: config-volume
        configMap:
          name: prometheus-config
      - name: prometheus-data
        emptyDir: {}
EOF

kubectl apply -f k8s/prometheus-deployment.yaml
echo "✅ Prometheus Deployment tạo thành công"

# 6. Tạo Service cho Prometheus
echo "🔧 Tạo Service cho Prometheus..."
cat > k8s/prometheus-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  selector:
    app: prometheus
  ports:
  - name: web
    port: 9090
    targetPort: 9090
  type: NodePort
EOF

kubectl apply -f k8s/prometheus-service.yaml
echo "✅ Prometheus Service tạo thành công"

# 7. Tạo Ingress cho Prometheus
echo "🔧 Tạo Ingress cho Prometheus..."
cat > k8s/prometheus-ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prometheus-ingress
  namespace: monitoring
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: prometheus.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus
            port:
              number: 9090
EOF

kubectl apply -f k8s/prometheus-ingress.yaml
echo "✅ Prometheus Ingress tạo thành công"

# 8. Tạo dịch vụ đơn giản sử dụng Node Exporter
echo "🔧 Tạo Node Exporter để thu thập metric từ node..."
cat > k8s/node-exporter.yaml << EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9100"
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:v1.6.1
        args:
        - "--path.procfs=/host/proc"
        - "--path.sysfs=/host/sys"
        ports:
        - containerPort: 9100
        resources:
          limits:
            cpu: 100m
            memory: 100Mi
          requests:
            cpu: 50m
            memory: 50Mi
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
EOF

kubectl apply -f k8s/node-exporter.yaml
echo "✅ Node Exporter tạo thành công"

# 9. Đợi và kiểm tra
echo "⏳ Đợi các pod khởi động..."
sleep 20

echo "🔍 Kiểm tra trạng thái Pod..."
kubectl get pods -n monitoring

# 10. Hiển thị URL truy cập
echo "🔍 URL truy cập Prometheus:"
minikube service prometheus -n monitoring --url

# 11. Thêm vào hosts để truy cập qua tên miền
echo "⚠️ Để truy cập qua tên miền prometheus.local, hãy thêm dòng sau vào file /etc/hosts:"
echo "$(minikube ip) prometheus.local"

# 12. Kiểm tra kết nối tunnel
echo "🔍 Kiểm tra xem minikube tunnel có đang chạy không..."
if pgrep -f "minikube tunnel" > /dev/null; then
  echo "✅ minikube tunnel đang chạy"
else
  echo "⚠️ minikube tunnel không chạy. Hãy chạy lệnh sau trong một terminal riêng biệt:"
  echo "minikube tunnel"
  
  # Khởi động tunnel trong nền
  echo "📝 Khởi động minikube tunnel trong nền..."
  nohup minikube tunnel > tunnel_monitoring.log 2>&1 &
  sleep 5
  echo "✅ Minikube tunnel đã được khởi động, log lưu ở tunnel_monitoring.log"
fi

echo "================================================================="
echo "✅ Cài đặt giám sát hoàn tất! 🎉"
echo "👉 Truy cập Prometheus theo một trong các cách:"
echo "  1. URL NodePort: $(minikube service prometheus -n monitoring --url)"
echo "  2. Hoặc http://prometheus.local (sau khi thêm vào /etc/hosts)"
echo "=================================================================" 