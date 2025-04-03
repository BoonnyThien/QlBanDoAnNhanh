# Hướng dẫn Thiết lập Môi trường Phát triển

## Yêu cầu hệ thống
- Docker Engine 20.10+
- Docker Compose 2.0+
- Kubernetes (Minikube hoặc EKS/GKE)
- kubectl
- PHP 8.1+
- Composer

## Các bước thiết lập

### 1. Cài đặt Docker
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose

# Windows
# Tải và cài đặt Docker Desktop từ https://www.docker.com/products/docker-desktop
```

### 2. Cài đặt Kubernetes
```bash
# Cài đặt Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Cài đặt kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### 3. Khởi động môi trường phát triển
```bash
# Clone repository
git clone [repository-url]
cd doannhanh

# Khởi động Docker containers
cd ~/doannhanh/docker && docker compose up -d

http://localhost:8080/
http://localhost:8080/admin/

# Thay đổi dự liệu file 
cd ~/doannhanh/docker && docker compose down
docker compose up -d
docker compose logs -f

# Khởi động Minikube
minikube start

# Áp dụng Kubernetes configurations
cd ~/doannhanh && kubectl apply -f k8s/
```

### 4. Kiểm tra cài đặt
```bash
# Kiểm tra Docker
docker ps

# Kiểm tra Kubernetes
kubectl get pods
kubectl get services

# Kiểm tra ứng dụng
curl http://localhost:8080
```

## Xử lý sự cố thường gặp

### Docker không khởi động
- Kiểm tra trạng thái Docker: `sudo systemctl status docker`
- Khởi động lại Docker: `sudo systemctl restart docker`

### Kubernetes không hoạt động
- Kiểm tra trạng thái Minikube: `minikube status`
- Khởi động lại Minikube: `minikube stop && minikube start`

### Lỗi kết nối database
- Kiểm tra logs của MySQL container: `docker logs mysql-container`
- Kiểm tra kết nối: `mysql -h localhost -u root -p` 