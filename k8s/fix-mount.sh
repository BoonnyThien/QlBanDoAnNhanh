#!/bin/bash

# Get the absolute path of the project root
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
echo "Project root: $PROJECT_ROOT"

# Force delete existing resources
echo "Cleaning up existing resources..."
kubectl delete pvc php-pvc --force --grace-period=0 2>/dev/null || true
kubectl delete pv php-pv --force --grace-period=0 2>/dev/null || true
kubectl delete deployment php-app --force --grace-period=0 2>/dev/null || true

# Copy PHP code to Minikube
echo "Copying PHP code to Minikube..."
minikube cp "$PROJECT_ROOT/phpCode" /mnt/data/php -r

# Create PV and PVC
echo "Creating PV and PVC..."
cat > "$PROJECT_ROOT/k8s/php-pv.yaml" << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: php-pv
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data/php
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: php-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 10Gi
EOF

# Apply configurations
echo "Applying configurations..."
kubectl apply -f "$PROJECT_ROOT/k8s/php-pv.yaml"
kubectl apply -f "$PROJECT_ROOT/k8s/deployment.yaml"

# Wait for PVC to be bound
echo "Waiting for PVC to be bound..."
while ! kubectl get pvc php-pvc -o jsonpath='{.status.phase}' | grep -q "Bound"; do
  echo "Waiting for PVC to be bound..."
  sleep 5
done

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=php --timeout=300s

# Check status
echo "Checking status..."
kubectl get pv
kubectl get pvc
kubectl get pods

echo "Fix completed!"