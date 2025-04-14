#!/bin/bash

# Get the absolute path of the project root
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
echo "Project root: $PROJECT_ROOT"

# Create necessary directories
echo "Creating data directories..."
sudo mkdir -p /mnt/data/mysql
sudo mkdir -p /mnt/data/php
sudo mkdir -p /mnt/data/backup
sudo chmod 777 /mnt/data/*

# Update PV paths in php-pv.yaml
echo "Updating PV paths..."
sed -i "s|path: .*|path: /mnt/data/mysql|g" "$PROJECT_ROOT/k8s/php-pv.yaml"
sed -i "s|path: .*|path: /mnt/data/php|g" "$PROJECT_ROOT/k8s/php-pv.yaml"
sed -i "s|path: .*|path: /mnt/data/backup|g" "$PROJECT_ROOT/k8s/php-pv.yaml"

# Update source path in deployment.yaml
echo "Updating deployment paths..."
sed -i "s|path: .*|path: $PROJECT_ROOT/phpCode|g" "$PROJECT_ROOT/k8s/deployment.yaml"

# Apply configurations
echo "Applying configurations..."
kubectl apply -f "$PROJECT_ROOT/k8s/php-pv.yaml"
kubectl apply -f "$PROJECT_ROOT/k8s/deployment.yaml"

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=php-app --timeout=300s

# Check deployment status
echo "Checking deployment status..."
kubectl get pods
kubectl get pv
kubectl get pvc

echo "Deployment completed!" 