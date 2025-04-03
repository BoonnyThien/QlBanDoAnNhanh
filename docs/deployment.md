# Quy trình Triển khai

## 1. Triển khai Development

### Bước 1: Build Docker images
```bash
# Build images
docker compose build

# Kiểm tra images
docker images
```

### Bước 2: Khởi động môi trường development
```bash
# Khởi động containers
docker compose up -d

# Kiểm tra trạng thái
docker compose ps
```

## 2. Triển khai Staging

### Bước 1: Build và push images
```bash
# Build images với tag staging
docker build -t registry.example.com/app:staging .

# Push lên registry
docker push registry.example.com/app:staging
```

### Bước 2: Triển khai lên Kubernetes
```bash
# Cập nhật image version trong deployment
kubectl set image deployment/app app=registry.example.com/app:staging -n staging

# Kiểm tra rollout
kubectl rollout status deployment/app -n staging
```

## 3. Triển khai Production

### Bước 1: Chuẩn bị release
```bash
# Tạo release branch
git checkout -b release/v1.0.0

# Tăng version trong các file cấu hình
# Commit và push
git commit -am "Release v1.0.0"
git push origin release/v1.0.0
```

### Bước 2: Build và push production images
```bash
# Build production images
docker build -t registry.example.com/app:1.0.0 .

# Push lên registry
docker push registry.example.com/app:1.0.0
```

### Bước 3: Triển khai lên production
```bash
# Áp dụng Kubernetes manifests
kubectl apply -f k8s/production/

# Kiểm tra rollout
kubectl rollout status deployment/app -n production
```

## Rollback Procedure

### Rollback Kubernetes deployment
```bash
# Xem lịch sử rollout
kubectl rollout history deployment/app -n production

# Rollback về version trước
kubectl rollout undo deployment/app -n production

# Hoặc rollback về version cụ thể
kubectl rollout undo deployment/app -n production --to-revision=2
```

### Rollback Docker images
```bash
# Pull version cũ
docker pull registry.example.com/app:1.0.0

# Cập nhật deployment
kubectl set image deployment/app app=registry.example.com/app:1.0.0 -n production
``` 