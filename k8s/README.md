# Triển khai Ứng dụng PHP và MySQL trên Kubernetes

Thư mục này chứa các tệp cấu hình Kubernetes và script để triển khai và quản lý ứng dụng PHP và MySQL trên cluster Kubernetes (Minikube).

## 🚀 Bắt đầu nhanh

Để triển khai ứng dụng với tất cả các vấn đề đã được sửa chữa, chạy:

```bash
chmod +x k8s/setup-and-repair.sh
./k8s/setup-and-repair.sh
```

Script này sẽ:
1. Kiểm tra và khởi động Minikube với giới hạn tài nguyên phù hợp (2 CPUs, 2GB RAM)
2. Dọn dẹp các tài nguyên cũ
3. Tạo tất cả các tài nguyên Kubernetes cần thiết
4. Triển khai ứng dụng
5. Cung cấp thông tin truy cập khi hoàn tất

## 📁 Danh sách Script

- `setup-and-repair.sh`: Script toàn diện để thiết lập và sửa tất cả các vấn đề
- `install-monitoring.sh`: Script để cài đặt hệ thống giám sát Prometheus

## 🛠️ Thành phần triển khai

- **Ứng dụng PHP**: Ứng dụng PHP đơn giản kết nối tới MySQL
- **Cơ sở dữ liệu MySQL**: MySQL 8.0 với dữ liệu mẫu
- **Dịch vụ**: ClusterIP cho MySQL và NodePort cho PHP
- **Lưu trữ**: EmptyDir cho lưu trữ dữ liệu (đơn giản hóa so với PV/PVC)
- **ConfigMaps**: Cho mã PHP và khởi tạo MySQL
- **Secrets**: Cho thông tin đăng nhập MySQL

## ⚠️ Các vấn đề đã sửa

Script thiết lập đã sửa một số vấn đề trong triển khai ban đầu:

1. **Cài đặt PDO MySQL**: Cài đặt trực tiếp extension PDO MySQL trong container PHP
2. **Lưu trữ đơn giản hóa**: Sử dụng emptyDir thay vì PVC để tránh các vấn đề về PV/PVC
3. **Deployment thay vì StatefulSet**: Đơn giản hóa triển khai MySQL
4. **Kiểm tra trạng thái Minikube**: Đảm bảo Minikube hoạt động trước khi triển khai
5. **Logs chi tiết**: Hiển thị logs khi có lỗi để dễ dàng khắc phục

## 📊 Giám sát

Để triển khai các thành phần giám sát:

```bash
chmod +x k8s/install-monitoring.sh
./k8s/install-monitoring.sh
```

Việc này sẽ cài đặt:
- Prometheus Operator CRDs
- Máy chủ Prometheus với giới hạn tài nguyên phù hợp
- Giao diện Prometheus

## 📋 Các bước kiểm tra thủ công

Sau khi triển khai, kiểm tra cài đặt:

```bash
# Kiểm tra tất cả tài nguyên
kubectl get all

# Kiểm tra trạng thái pod
kubectl get pods

# Truy cập ứng dụng PHP
minikube service php-service

# Kết nối tới MySQL
kubectl exec -it $(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- mysql -uroot -prootpassword
```

## 🔄 Xử lý sự cố

Nếu gặp vấn đề:

1. Kiểm tra trạng thái pod: `kubectl get pods`
2. Xem chi tiết pod: `kubectl describe pod <tên-pod>`
3. Xem logs: `kubectl logs <tên-pod>`
4. Khởi động lại triển khai: `./k8s/fix-all-issues.sh`

## 🧪 Kiểm tra ứng dụng

Ứng dụng PHP sẽ hiển thị:
- Thông điệp chào mừng
- Trạng thái kết nối MySQL
- Danh mục sản phẩm từ cơ sở dữ liệu
- Thông tin cấu hình PHP

Cơ sở dữ liệu MySQL bao gồm:
- Bảng mẫu (categories, products)
- Dữ liệu mẫu cho kiểm thử 