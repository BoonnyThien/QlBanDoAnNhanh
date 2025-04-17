# 🚀 Hướng Dẫn Triển Khai Kubernetes

## 📋 Các File Quan Trọng

### 1. File Triển Khai Chính
- `setup_and_repair.sh`: Script chính để cài đặt và sửa lỗi tự động
- `setup-minikube.sh`: Cấu hình Minikube ban đầu

### 2. File Cấu Hình Cốt Lõi
- `mysql-deployment.yaml`: Triển khai MySQL
- `mysql-service.yaml`: Service cho MySQL
- `php-deployment.yaml`: Triển khai PHP
- `php-service.yaml`: Service cho PHP
- `ingress.yaml`: Cấu hình Ingress

### 3. File Bảo Mật
- `rbac.yaml`: Phân quyền RBAC
- `network-policies.yaml`: Chính sách mạng
- `secrets.yaml`: Quản lý secrets

### 4. File Lưu Trữ
- `pv.yaml`: Persistent Volume
- `pvc.yaml`: Persistent Volume Claim
- `storageclass.yaml`: Storage Class

### 5. File Giám Sát
- `monitoring.yaml`: Cấu hình giám sát
- `prometheus-operator.yaml`: Cài đặt Prometheus

## 🛠️ Hướng Dẫn Sử Dụng

### 1. Triển Khai Ban Đầu
```bash
# Cấp quyền thực thi cho script
chmod +x k8s/setup_and_repair.sh

# Chạy script cài đặt
./k8s/setup_and_repair.sh
```

Script này sẽ tự động:
- ✅ Kiểm tra và khởi động Minikube
- ✅ Xóa tài nguyên cũ (nếu có)
- ✅ Tạo Secret và ConfigMap
- ✅ Triển khai MySQL và PHP
- ✅ Cấu hình Ingress

### 2. Kiểm Tra Trạng Thái
```bash
# Xem trạng thái pods
kubectl get pods

# Xem logs
kubectl logs -l app=php
kubectl logs -l app=mysql
```

### 3. Truy Cập Ứng Dụng
```bash
# Lấy URL ứng dụng
minikube service php-service --url
```

## 🔒 Thiết Lập Bảo Mật

### 1. Áp Dụng RBAC
```bash
kubectl apply -f k8s/rbac.yaml
```

### 2. Áp Dụng Network Policies
```bash
kubectl apply -f k8s/network-policies.yaml
```

### 3. Quản Lý Secrets
```bash
kubectl apply -f k8s/secrets.yaml
```

## 📊 Cài Đặt Giám Sát

### 1. Triển Khai Prometheus & Grafana
```bash
chmod +x k8s/install-monitoring.sh
./k8s/install-monitoring.sh
```

### 2. Truy Cập Dashboard
```bash
# Mở Grafana dashboard
kubectl port-forward svc/grafana 3000:3000
```

## 🔍 Xử Lý Sự Cố

### 1. Pod Không Khởi Động
```bash
# Kiểm tra chi tiết pod
kubectl describe pod <tên-pod>

# Xem logs
kubectl logs <tên-pod>
```

### 2. Lỗi Kết Nối MySQL
```bash
# Kiểm tra service
kubectl get svc mysql-service

# Kiểm tra endpoints
kubectl get endpoints mysql-service
```

### 3. Lỗi Persistent Volume
```bash
# Kiểm tra trạng thái PV/PVC
kubectl get pv,pvc
```

## 📝 Lưu Ý Quan Trọng

1. **Yêu Cầu Hệ Thống**
   - Minikube v1.20+
   - Kubectl v1.20+
   - Docker 20.10+

2. **Tài Nguyên Tối Thiểu**
   - CPU: 2 cores
   - RAM: 4GB
   - Disk: 20GB

3. **Ports Sử Dụng**
   - 80: HTTP
   - 3306: MySQL
   - 9090: Prometheus
   - 3000: Grafana

## 🆘 Hỗ Trợ

Nếu gặp vấn đề:
1. Chạy script sửa lỗi: `./k8s/fix-all.sh`
2. Kiểm tra logs: `kubectl logs -l app=<tên-app>`
3. Xem events: `kubectl get events --sort-by=.metadata.creationTimestamp`

## 🔄 Quy Trình Khôi Phục

Nếu hệ thống gặp sự cố:
1. Sao lưu dữ liệu: `./k8s/backup-restore.sh backup`
2. Xóa triển khai hiện tại: `kubectl delete -f k8s/`
3. Chạy lại script cài đặt: `./k8s/setup_and_repair.sh`
4. Khôi phục dữ liệu: `./k8s/backup-restore.sh restore` 