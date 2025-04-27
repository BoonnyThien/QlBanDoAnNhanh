#!/bin/bash

echo "🚀 11 Thiết lập audit logging..."

# Copy audit-policy.yaml vào Minikube
minikube cp k8s/security/audit-policy.yaml /mnt/audit-policy.yaml

# Khởi động lại Minikube với audit logging
minikube stop
minikube start \
  --driver=docker \
  --kubernetes-version=v1.32.0 \
  --memory=4096 \
  --cpus=4 \
  --extra-config=kubelet.cgroup-driver=systemd \
  --extra-config=apiserver.audit-policy-file=/mnt/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=/var/log/kubernetes/audit.log
if [ $? -eq 0 ]; then
  echo "✅ Minikube khởi động với audit logging thành công!"
else
  echo "❌ Lỗi khi khởi động Minikube!"
  exit 1
fi

# Đợi API server sẵn sàng
echo "⏳ Đợi Kubernetes API server sẵn sàng..."
kubectl wait --for=condition=ready pod -l component=kube-apiserver -n kube-system --timeout=300s
if [ $? -eq 0 ]; then
  echo "✅ API server sẵn sàng!"
else
  echo "❌ Lỗi: API server không sẵn sàng!"
  exit 1
fi

# Kiểm tra audit log
echo "🔍 Kiểm tra audit log..."
minikube ssh "sudo cat /var/log/kubernetes/audit.log" > audit.log
if [ -s audit.log ]; then
  echo "✅ Audit log được ghi thành công!"
else
  echo "❌ Lỗi: Audit log trống hoặc không tồn tại!"
  exit 1
fi

echo "✅ Hoàn tất thiết lập audit logging!"