# Hướng dẫn Bảo mật Hệ thống

## Tổng quan
Tài liệu này mô tả các lớp bảo mật được triển khai trong hệ thống, bao gồm:
- RBAC (Role-Based Access Control)
- Network Policies
- Secrets Management
- Container Security
- Data Protection
- Monitoring & Backup

## 1. RBAC (Role-Based Access Control)
### Mục đích
- Kiểm soát quyền truy cập trong cluster
- Phân quyền chi tiết cho từng service
- Giảm thiểu rủi ro từ việc lạm dụng đặc quyền

### Cấu hình
```yaml
# k8s/rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: php-app-sa
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mysql-sa
```

### Áp dụng
```bash
kubectl apply -f k8s/rbac.yaml
```

## 2. Network Policies
### Mục đích
- Kiểm soát luồng traffic giữa các pods
- Cô lập các services
- Bảo vệ database khỏi truy cập trái phép

### Cấu hình chính
```yaml
# k8s/network-policies.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-php-to-mysql
spec:
  podSelector:
    matchLabels:
      app: mysql
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: php
```

## 3. Secrets Management
### Mục đích
- Bảo vệ thông tin nhạy cảm
- Quản lý credentials an toàn
- Rotation keys định kỳ

### Triển khai
```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  db-password: <base64-encoded>
  api-key: <base64-encoded>
```

## 4. Container Security
### Mục đích
- Quét lỗ hổng bảo mật container
- Non-root user execution
- Giới hạn capabilities

### Best Practices
- Sử dụng official base images
- Regular security scanning
- Minimal container images

## 5. Data Protection
### Mục đích
- Mã hóa dữ liệu at-rest
- Backup tự động
- Data masking cho thông tin nhạy cảm

### Cấu hình
```yaml
# k8s/data-protection.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: encrypted-storage
spec:
  storageClassName: encrypted-storage
```

## 6. Monitoring & Backup
### Mục đích
- Giám sát bảo mật realtime
- Phát hiện xâm nhập
- Backup tự động và khôi phục

### Triển khai
```yaml
# k8s/monitoring.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: security-monitor
```

## Script Triển khai Bảo mật
Tạo file `k8s/deploy-security.sh`:

```bash
#!/bin/bash

echo "🔒 Triển khai các cấu hình bảo mật..."

# 1. RBAC
echo "1️⃣ Áp dụng RBAC..."
kubectl apply -f k8s/rbac.yaml

# 2. Network Policies
echo "2️⃣ Áp dụng Network Policies..."
kubectl apply -f k8s/network-policies.yaml

# 3. Secrets
echo "3️⃣ Tạo Secrets..."
kubectl apply -f k8s/secrets.yaml

# 4. Container Security
echo "4️⃣ Quét bảo mật container..."
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image your-app-image:latest

# 5. Data Protection
echo "5️⃣ Áp dụng Data Protection..."
kubectl apply -f k8s/data-protection.yaml

# 6. Monitoring
echo "6️⃣ Thiết lập Monitoring..."
kubectl apply -f k8s/monitoring.yaml

echo "✅ Hoàn tất triển khai bảo mật!"
```

## Kiểm tra Bảo mật
```bash
#Kiểm trả các bảo mật
chmod +x k8s/container-security.sh
./k8s/container-security.sh
# Kiểm tra RBAC
kubectl auth can-i --as system:serviceaccount:default:php-app-sa get pods

# Kiểm tra Network Policies
kubectl describe networkpolicies

# Kiểm tra Secrets
kubectl get secrets

# Kiểm tra Monitoring
kubectl get servicemonitors
```

## Lưu ý Quan trọng
1. Cập nhật secrets định kỳ
2. Quét bảo mật container thường xuyên
3. Kiểm tra logs bảo mật hàng ngày
4. Backup dữ liệu định kỳ
5. Cập nhật patches bảo mật kịp thời

## Cấp quyền thực thi cho script
```bash
chmod +x k8s/deploy-security.sh
./k8s/deploy-security.sh


```

## Cập nhật tài liệu bảo mật
Tôi đã cập nhật tài liệu để bao gồm các thông tin chi tiết hơn về mục đích và cách triển khai của từng component bảo mật. Người dùng có thể dễ dàng hiểu và áp dụng các biện pháp bảo mật này vào hệ thống của họ. 