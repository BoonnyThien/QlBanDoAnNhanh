# Ứng dụng PHP Đồ Ăn Nhanh trên Kubernetes

## Giới thiệu
Dự án này triển khai một ứng dụng web PHP về đồ ăn nhanh trên Kubernetes, sử dụng MySQL làm cơ sở dữ liệu.

## Vấn đề và Giải pháp
Trong quá trình triển khai, chúng ta gặp phải một số vấn đề:

1. **Vấn đề tên service MySQL**: Tên `mysql_db` không hợp lệ trong Kubernetes (không chấp nhận dấu gạch dưới)
2. **Vấn đề kết nối PHP-MySQL**: Cấu hình kết nối MySQL trong PHP không đúng
3. **Vấn đề deployment PHP**: Pod PHP không khởi động

## Cách khắc phục

Chúng tôi đã tạo các script sửa chữa:

1. `fix_mysql_service.sh`: Tạo service MySQL đúng tên (`mysql` và `mysql-db`)
2. `fix_php_config.sh`: Cập nhật cấu hình kết nối PHP-MySQL 
3. `fix_php_error_config.sh`: Cấu hình hiển thị lỗi PHP
4. `fix_php_deployment.sh`: Tạo lại deployment PHP đúng cách
5. `fix_php_service.sh`: Tạo service cho PHP
6. `fix_all.sh`: Script chính chạy tất cả các bước sửa chữa

## Cách sử dụng

### Yêu cầu
- Minikube
- kubectl
- Docker

### Các bước triển khai

1. **Khởi động minikube**:
   ```bash
   minikube start --driver=docker --memory=3072 --cpus=2 --addons=ingress
   ```

2. **Chạy script khắc phục**:
   ```bash
   chmod +x fix_all.sh
   ./fix_all.sh
   ```

3. **Kiểm tra trạng thái**:
   ```bash
   kubectl get pods
   kubectl get services
   ```

4. **Truy cập ứng dụng**:
   ```bash
   minikube service php-service --url
   ```

## Xử lý sự cố

- **Pod MySQL không khởi động**: Kiểm tra logs với `kubectl logs <mysql-pod-name>`
- **Pod PHP không khởi động**: Kiểm tra logs với `kubectl logs <php-pod-name>`
- **Không thể kết nối đến MySQL**: Kiểm tra service với `kubectl get svc mysql`
- **Lỗi config**: Kiểm tra ConfigMaps với `kubectl get configmaps`

## Cấu trúc dự án

- **k8s/**: Chứa các script và cấu hình Kubernetes
- **docker/**: Chứa mã nguồn PHP và SQL
- **fix_*.sh**: Các script sửa chữa

## Lưu ý quan trọng

- Đảm bảo cập nhật file `/etc/hosts` với IP minikube và tên miền `doannhanh.local`
- PHP và MySQL cần thời gian để khởi động hoàn toàn, đặc biệt là quá trình khởi tạo cơ sở dữ liệu 