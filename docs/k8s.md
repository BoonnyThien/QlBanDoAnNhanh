# Hệ thống Quản lý Bán Đồ Ăn Nhanh trên Kubernetes

## Giới thiệu

Dự án Quản lý Bán Đồ Ăn Nhanh (QlBanDoAnNhanh) là một hệ thống web được triển khai trên Kubernetes, cung cấp giải pháp quản lý bán hàng thực phẩm trực tuyến với hai giao diện chính:

- **Frontend**: Dành cho người dùng cuối, hỗ trợ xem sản phẩm, đặt hàng, và gửi phản hồi.
- **Admin**: Dành cho quản trị viên, quản lý sản phẩm, đơn hàng, bài viết, và thống kê.

Hệ thống được container hóa bằng Docker, triển khai trên cụm Kubernetes cục bộ (Minikube), và sử dụng Cloudflare Tunnel để truy cập từ Internet. Dự án thể hiện khả năng tích hợp các công nghệ hiện đại để xây dựng một ứng dụng web có tính sẵn sàng cao, dễ mở rộng, và bảo mật.

## Công nghệ sử dụng

- **Minikube**: Công cụ chạy Kubernetes cục bộ, cho phép triển khai và quản lý cụm Kubernetes trên máy tính cá nhân.
- **Kubernetes (K8s)**: Hệ thống quản lý container, tự động hóa triển khai, mở rộng, và quản lý ứng dụng container hóa.
- **Docker**: Công nghệ container hóa, đóng gói ứng dụng PHP và MySQL thành các container độc lập.
- **MySQL**: Cơ sở dữ liệu quan hệ lưu trữ thông tin sản phẩm (tbl_sanpham), tài khoản (tbl_dangky), đơn hàng (tbl_cart_registered, tbl_cart_unregistered), và các dữ liệu khác.
- **PHP**: Ngôn ngữ lập trình phía server, xử lý logic nghiệp vụ cho cả giao diện Frontend và Admin.
- **Apache**: Web server chạy ứng dụng PHP, được cấu hình để hỗ trợ mod_rewrite và symbolic links.
- **Ingress (NGINX)**: Định tuyến lưu lượng HTTP/HTTPS từ bên ngoài vào các service trong cụm Kubernetes.
- **Cloudflare Tunnel**: Tạo đường hầm từ cụm Minikube ra Internet, cho phép truy cập website qua URL công khai.
- **ConfigMap**: Quản lý cấu hình Apache, PHP, và MySQL (ví dụ: apache-config, php-config, mysql-config).
- **Secret**: Lưu trữ thông tin nhạy cảm như mật khẩu MySQL (mysql-secret).
- **PersistentVolumeClaim (PVC)**: Lưu trữ dữ liệu MySQL bền vững, đảm bảo dữ liệu không mất khi container khởi động lại.
- **Docker Hub**: Lưu trữ image buithienboo/qlbandoannhanh-php-app:1.1, chứa mã nguồn và cấu hình ứng dụng.

## Ứng dụng thực tiễn

- **Người dùng cuối**: Truy cập giao diện Frontend để duyệt sản phẩm, thêm vào giỏ hàng, đặt hàng, gửi phản hồi, và đọc bài viết.
- **Quản trị viên**: Quản lý danh mục sản phẩm, đơn hàng, tài khoản người dùng, bài viết, và theo dõi thống kê bán hàng qua giao diện Admin.
- **Nhà phát triển/DevOps**: Học cách triển khai ứng dụng container hóa trên Kubernetes, quản lý cấu hình, và mở rộng hệ thống.

## Yêu cầu hệ thống

- Minikube
- Kubernetes (kubectl)
- Docker Engine 20.10+
- Git
- Cloudflare Tunnel CLI (cloudflared)

## Các bước thiết lập

### 1. Clone repository
```bash
git clone https://github.com/BoonnyThien/QlBanDoAnNhanh.git
cd QlBanDoAnNhanh
```

### 2. Chuẩn bị môi trường

- Đảm bảo Minikube, kubectl, và Docker đã được cài đặt.
- Đảm bảo thư mục `k8s/` chứa script `setup_and_repair.sh` và các file cấu hình Kubernetes.

### 3. Chạy script thiết lập
```bash
cd ~/QlBanDoAnNhanh/k8s
chmod +x setup_and_repair.sh
./setup_and_repair.sh
```

### 4. Truy cập ứng dụng

#### Sử dụng Cloudflare Tunnel (URL thay đổi mỗi lần chạy)
- Frontend: URL sẽ được hiển thị trong log của Cloudflare Tunnel
- Admin: URL sẽ được hiển thị trong log của Cloudflare Tunnel

#### Hoặc sử dụng Ingress cục bộ:

Cập nhật file `/etc/hosts`:
```bash
echo "192.168.49.2 frontend.doannhanh.local admin.doannhanh.local" | sudo tee -a /etc/hosts
```

Truy cập:
- Frontend: 'http://frontend.doannhanh.local'
- Admin: 'http://admin.doannhanh.local'

### 5. Kiểm tra trạng thái
```bash
# Kiểm tra pods
kubectl get pods

# Kiểm tra services
kubectl get services

# Kiểm tra Ingress
kubectl get ingress

# Kiểm tra logs của pod
kubectl logs -l app=mysql
kubectl logs -l app=php
kubectl logs -l app=php-admin
```

## Xử lý sự cố thường gặp

### Minikube không khởi động

Kiểm tra trạng thái:
```bash
minikube status
```

Khởi động lại:
```bash
minikube stop
minikube start --driver=docker
```

### Pods không ở trạng thái Running

Kiểm tra trạng thái pods:
```bash
kubectl get pods
```

Xem chi tiết lỗi:
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

Xóa và chạy lại script:
```bash
cd ~/QlBanDoAnNhanh/k8s
./setup_and_repair.sh
```

### Lỗi kết nối MySQL

Kiểm tra trạng thái MySQL pod:
```bash
kubectl logs -l app=mysql
```

Kiểm tra kết nối:
```bash
kubectl exec -it $(kubectl get pod -l app=mysql -o jsonpath="{.items[0].metadata.name}") -- mysql -u app_user -puserpass -e "SELECT 1;"
```

Đảm bảo Secret mysql-secret tồn tại:
```bash
kubectl get secret mysql-secret -o yaml
```

### Lỗi Ingress hoặc Cloudflare Tunnel

Kiểm tra Ingress:
```bash
kubectl describe ingress php-ingress
```

Kiểm tra Cloudflare Tunnel:
```bash
cloudflared tunnel list
```

Khởi động lại tunnel:
```bash
kubectl delete pod -l app=cloudflared
```

## Lệnh bổ sung

### Xóa toàn bộ tài nguyên Kubernetes
```bash
cd ~/QlBanDoAnNhanh/k8s
kubectl delete -f .
minikube delete
```

### Truy cập pod
```bash
# Truy cập MySQL pod
kubectl exec -it $(kubectl get pod -l app=mysql -o jsonpath="{.items[0].metadata.name}") -- bash

# Truy cập PHP Frontend pod
kubectl exec -it $(kubectl get pod -l app=php -o jsonpath="{.items[0].metadata.name}") -- bash

# Truy cập PHP Admin pod
kubectl exec -it $(kubectl get pod -l app=php-admin -o jsonpath="{.items[0].metadata.name}") -- bash
```

### Kiểm tra cấu hình
```bash
# Kiểm tra ConfigMap
kubectl get configmap
kubectl describe configmap mysql-config

# Kiểm tra Secret
kubectl get secret mysql-secret -o yaml

# Kiểm tra PVC
kubectl get pvc mysql-pvc
```

## Thành phần chính và cách hoạt động

### Script setup_and_repair.sh:

- Khởi động Minikube và kiểm tra trạng thái cụm.
- Dọn dẹp tài nguyên cũ (kubectl delete).
- Tạo Secret (mysql-secret) chứa mật khẩu MySQL.
- Kéo image từ Docker Hub (buithienboo/qlbandoannhanh-php-app:1.1).
- Tạo ConfigMap (mysql-init, mysql-config, apache-config, php-config) từ file SQL và cấu hình.
- Tạo PersistentVolumeClaim (mysql-pvc) cho MySQL.
- Triển khai MySQL Deployment và Service.
- Triển khai PHP Frontend và Admin Deployments cùng Services.
- Tạo Ingress và Cloudflare Tunnel để truy cập công khai.
- Kiểm tra trạng thái pods, extension PHP (pdo_mysql), và kết nối MySQL.

### Docker Image:

Image buithienboo/qlbandoannhanh-php-app:1.1 chứa:

- Mã nguồn PHP cho Frontend (/var/www/html/user/) và Admin (/var/www/html/admin/).
- File SQL (qlbandoannhanh.sql) để khởi tạo database.
- Cấu hình Apache và PHP với UTF-8 encoding.

### Kubernetes Resources:

- **Deployments**: mysql, php-deployment, php-admin-deployment để chạy containers.
- **Services**: mysql-service, php-app-service, php-admin-service để liên kết pods.
- **Ingress**: php-ingress định tuyến lưu lượng đến Frontend và Admin.
- **ConfigMap/Secret**: Quản lý cấu hình và thông tin nhạy cảm.
- **PVC**: Lưu trữ dữ liệu MySQL bền vững.

### Database:

- Database qlbandoannhanh chứa các bảng như tbl_sanpham, tbl_cart_details, tbl_admin, v.v.
- Khởi tạo từ file qlbandoannhanh.sql thông qua ConfigMap mysql-init.

### Cloudflare Tunnel:

- Chuyển tiếp php-app-service đến localhost:8080 và php-admin-service đến localhost:8081.
- Tạo URL công khai cho Frontend và Admin (URL thay đổi mỗi lần chạy).

## Các script bổ sung trong thư mục k8s

Dự án còn bao gồm nhiều script bổ sung trong thư mục `k8s/`:

- **Các script triển khai từng bước**: `deploy_php_step_*.sh` - Các script triển khai từng phần của ứng dụng
- **Script bảo mật**: `container-security.sh` - Cấu hình bảo mật cho container
- **Script giám sát**: `install-monitoring.sh` - Cài đặt công cụ giám sát Kubernetes
- **Các file cấu hình Kubernetes**: `*.yaml` - Các file cấu hình cho các thành phần Kubernetes
- **Log files**: Các file log cho Cloudflare Tunnel và port forwarding

## Truy cập và sử dụng

- **Frontend**: Xem sản phẩm, đặt hàng, gửi phản hồi qua URL được cung cấp bởi Cloudflare Tunnel.
- **Admin**: Quản lý hệ thống qua URL được cung cấp bởi Cloudflare Tunnel.
- **Đăng nhập Admin**: Sử dụng tài khoản trong bảng tbl_admin (khởi tạo từ qlbandoannhanh.sql).