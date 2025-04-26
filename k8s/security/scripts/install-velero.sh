#!/bin/bash

echo "🔧 Bắt đầu cài đặt Velero để backup Kubernetes..."

# 1. Cài đặt Velero CLI
echo "1️⃣ Cài đặt Velero CLI..."
VELERO_VERSION="v1.12.0"
if ! command -v velero &> /dev/null; then
  curl -L https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION}-linux-amd64.tar.gz | tar xz
  sudo mv velero-${VELERO_VERSION}-linux-amd64/velero /usr/local/bin/
  rm -rf velero-${VELERO_VERSION}-linux-amd64
fi

# 2. Tạo namespace velero
echo "2️⃣ Tạo namespace velero..."
kubectl create namespace velero --dry-run=client -o yaml | kubectl apply -f -

# 3. Cài đặt MinIO làm backend lưu trữ
echo "3️⃣ Cài đặt MinIO làm backend lưu trữ..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
  namespace: velero
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
      - name: minio
        image: minio/minio:latest
        args:
        - server
        - /data
        - --console-address
        - ":9001"
        env:
        - name: MINIO_ROOT_USER
          value: "minioadmin"
        - name: MINIO_ROOT_PASSWORD
          value: "minioadmin"
        ports:
        - containerPort: 9000
        - containerPort: 9001
        volumeMounts:
        - name: data
          mountPath: /data
      volumes:
      - name: data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: velero
spec:
  ports:
  - port: 9000
    targetPort: 9000
    name: api
  - port: 9001
    targetPort: 9001
    name: console
  selector:
    app: minio
EOF

# Đợi MinIO khởi động
echo "⏳ Đợi MinIO khởi động..."
sleep 20
kubectl get pods -n velero

# 4. Tạo file credentials cho Velero
echo "4️⃣ Tạo file credentials cho Velero..."
cat << EOF > credentials-velero
[default]
aws_access_key_id = minioadmin
aws_secret_access_key = minioadmin
EOF

# 5. Cài đặt Velero trên cluster
echo "5️⃣ Cài đặt Velero trên cluster..."
if velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.0.0 \
  --bucket velero-backups \
  --secret-file ./credentials-velero \
  --backup-location-config region=us-west-2,s3ForcePathStyle=true,s3Url=http://minio.velero.svc:9000 \
  --snapshot-location-config region=us-west-2 \
  --namespace velero; then
  echo "✅ Cài Velero thành công!"
else
  echo "❌ Lỗi khi cài Velero!"
  exit 1
fi

# 6. Kiểm tra trạng thái Velero
echo "⏳ Đợi Velero khởi động..."
sleep 30
kubectl get pods -n velero

echo "✅ Hoàn tất cài đặt Velero!"