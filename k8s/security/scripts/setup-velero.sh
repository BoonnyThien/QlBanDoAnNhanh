#!/bin/bash

echo "🚀 9.1 Thiết lập backup với Velero..."

# Kiểm tra và cài Velero CLI
if ! command -v velero &> /dev/null; then
  echo "🔧 Cài đặt Velero CLI..."
  curl -L https://github.com/vmware-tanzu/velero/releases/download/v1.12.0/velero-v1.12.0-linux-amd64.tar.gz | tar -xz -C /tmp
  sudo mv /tmp/velero-v1.12.0-linux-amd64/velero /usr/local/bin/
fi

# Cài Velero server và CRDs
echo "🔧 Cài đặt Velero server..."
cat << EOF > k8s/security/velero-credentials
[default]
aws_access_key_id = your-access-key-id
aws_secret_access_key = your-secret-access-key
EOF

velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.10.0 \
  --bucket qlbandoannhanh-backup \
  --secret-file k8s/security/velero-credentials \
  --use-volume-snapshots=false \
  --backup-location-config region=us-east-1 \
  --namespace default

if [ $? -eq 0 ]; then
  echo "✅ Cài Velero server thành công!"
else
  echo "❌ Lỗi khi cài Velero server!"
  exit 1
fi

# Đợi Velero sẵn sàng
echo "⏳ Đợi Velero Pods sẵn sàng..."
kubectl wait --for=condition=ready pod -l component=velero -n default --timeout=300s

# Tạo backup
echo "🔄 Tạo backup cho namespace default..."
velero backup create qlbandoannhanh-backup --include-namespaces default --namespace default
if [ $? -eq 0 ]; then
  echo "✅ Tạo backup thành công!"
else
  echo "❌ Lỗi khi tạo backup!"
  exit 1
fi

echo "✅ Hoàn tất thiết lập backup với Velero!"