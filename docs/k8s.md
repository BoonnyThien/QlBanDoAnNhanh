# Hệ thống Quản lý bán đồ ăn nhanh trên Kubernetes

Tài liệu này mô tả tổng quan về hệ thống Quản lý bán đồ ăn nhanh được triển khai trên Kubernetes sử dụng Minikube.

## Giới thiệu

Dự án này triển khai một ứng dụng web quản lý cửa hàng đồ ăn nhanh trên môi trường Kubernetes, bao gồm:
- Giao diện quản lý sản phẩm, danh mục, đơn hàng
- Giao diện khách hàng để đặt hàng
- Hệ thống thanh toán và phản hồi
- Quản lý người dùng và phân quyền

## Bố cục dự án

```
.
├── k8s/
│   └── setup_and_repair.sh    # Script tự động triển khai ứng dụng
└── [mã nguồn PHP ứng dụng]    # Được đóng gói trong Docker image
```

## Kiến trúc hệ thống

![Kiến trúc hệ thống](/docs/imgs/architecture.png)

Hệ thống bao gồm các thành phần chính:

1. **MySQL Pod**: 
   - Lưu trữ dữ liệu ứng dụng
   - Sử dụng PersistentVolume để duy trì dữ liệu
   - Khởi tạo cơ sở dữ liệu từ script SQL

2. **PHP/Apache Pod**: 
   - Chạy ứng dụng web PHP
   - Kết nối đến MySQL
   - Image Docker: `buithienboo/qlbandoannhanh-php-app:1.1`

3. **Ingress**: 
   - Điều hướng truy cập từ bên ngoài vào ứng dụng
   - Cấu hình domain `doannhanh.local`

4. **ConfigMaps và Secrets**:
   - Lưu trữ cấu hình và thông tin nhạy cảm

## Cơ sở dữ liệu

Cơ sở dữ liệu `qlbandoannhanh` gồm các bảng:
- Quản lý sản phẩm (`tbl_sanpham`, `tbl_danhmuc`)
- Quản lý giỏ hàng (`tbl_cart_details`, `tbl_cart_registered`, `tbl_cart_unregistered`)
- Quản lý người dùng (`tbl_admin`, `tbl_dangky`)
- Quản lý nội dung (`tbl_baiviet`, `tbl_comments`, `tbl_phanhoi`)
- Thống kê (`tbl_thongke`)

## Yêu cầu hệ thống

- Docker
- Minikube v1.35.0 trở lên
- kubectl
- Hệ điều hành Linux (Ubuntu 22.04 được khuyến nghị)
- Ít nhất 4GB RAM và 4 CPU cores dành cho Minikube

## Hướng dẫn triển khai

### Cách 1: Sử dụng script tự động

1. Đảm bảo Docker đã được cài đặt và đang chạy
2. Chạy script triển khai:
```bash
cd ~/doannhanh
.ColorEmoji.sh
cd ~/doannhanh/k8s
./setup_and_repair.sh
```
3. Script sẽ tự động thực hiện 17 bước triển khai:
   - Khởi động Minikube
   - Dọn dẹp tài nguyên cũ (nếu có)
   - Tạo Secret cho MySQL
   - Kiểm tra và kéo Docker image
   - Tạo các ConfigMap cần thiết
   - Tạo PersistentVolumeClaim
   - Triển khai MySQL
   - Triển khai PHP Application
   - Tạo Ingress
   - Cập nhật file hosts
   - Thiết lập Cloudflare Tunnel (nếu cần)
   - Kiểm tra kết nối và hoạt động của ứng dụng

### Cách 2: Thiết lập thủ công

Xem phần "Quy trình triển khai" trong [tài liệu đầy đủ](/docs/k8s-full.md) để biết các bước chi tiết.

## Truy cập ứng dụng

Sau khi triển khai thành công:

1. Thêm dòng sau vào file `/etc/hosts`:
   ```
   192.168.49.2 doannhanh.local
   ```
   (Thay `192.168.49.2` bằng IP của Minikube từ lệnh `minikube ip`)

2. Truy cập ứng dụng qua trình duyệt:
   - URL: http://doannhanh.local

3. Thông tin đăng nhập admin:
   - URL: http://doannhanh.local/admincp
   - Tài khoản: admin
   - Mật khẩu: 123456

## Sửa lỗi thường gặp

### Kiểm tra trạng thái pods
```bash
kubectl get pods
```

### Kiểm tra logs
```bash
# Xem logs của pod PHP
kubectl logs $(kubectl get pods -l app=php -o jsonpath="{.items[0].metadata.name}")

# Xem logs của pod MySQL
kubectl logs $(kubectl get pods -l app=mysql -o jsonpath="{.items[0].metadata.name}")
```

### Khởi động lại ứng dụng
```bash
# Chạy lại script
./k8s/setup_and_repair.sh
```

### Ingress không hoạt động
```bash
# Kiểm tra Ingress
kubectl get ingress

# Kích hoạt lại Ingress addon
minikube addons enable ingress
```

### Xóa và triển khai lại từ đầu
```bash
# Xóa toàn bộ resource
kubectl delete deployment --all
kubectl delete service --all
kubectl delete ingress --all
kubectl delete configmap --all
kubectl delete secret --all
kubectl delete pvc --all

# Chạy lại script
./k8s/setup_and_repair.sh
```

## Thông tin thêm

- Docker Image: `buithienboo/qlbandoannhanh-php-app:1.1`
- Mã nguồn: [GitHub Repository](https://github.com/thinboonny/doannhanh)
- Liên hệ: [buithien14112003@email.com](mailto:buithien14112003@email.com)
