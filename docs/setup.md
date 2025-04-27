# Hướng dẫn Thiết lập Môi trường Docker cho Dự án Quản lý Bán Đồ Ăn Nhanh

## Yêu cầu hệ thống

- Docker Engine 20.10+
- Docker Compose 2.0+
- PHP 8.1+
- MySQL 8.0+
- Git

## Các bước thiết lập

### 1. Clone repository
```bash
git clone [repository-url]
cd QlBanDoAnNhanh
```

### 2. Chuẩn bị source code

- Đảm bảo thư mục `phpCode/` chứa mã nguồn ứng dụng
- Đảm bảo thư mục `phpCode/admin/` chứa mã nguồn giao diện admin
- Đảm bảo thư mục `phpCode/database/` chứa file `qlbandoannhanh.sql`

### 3. Khởi động Docker containers
```bash
cd ~/QlBanDoAnNhanh/docker
docker compose up -d
```

### 4. Truy cập ứng dụng

- Giao diện người dùng: 'http://localhost:8080/'
- Giao diện admin: 'http://localhost:8081/'

### 5. Cập nhật hoặc rebuild containers
```bash
cd ~/QlBanDoAnNhanh/docker
docker compose down
docker compose up --build -d
```

### 6. Kiểm tra trạng thái
```bash
# Kiểm tra containers đang chạy
docker ps

# Kiểm tra logs của containers
docker compose logs -f

# Kiểm tra kết nối MySQL
docker exec -it mysql-service mysql -u root -prootpass
```

## Xử lý sự cố thường gặp

### Lỗi Docker không khởi động

Kiểm tra trạng thái Docker:
```bash
sudo systemctl status docker
```

Khởi động lại Docker:
```bash
sudo systemctl restart docker
```

### Lỗi container không chạy

Xem logs chi tiết:
```bash
docker logs php_app
docker logs php_admin
docker logs mysql-service
```

Xóa và rebuild containers:
```bash
cd ~/QlBanDoAnNhanh/docker
docker compose down
docker compose up --build -d
```

### Lỗi kết nối database

Kiểm tra thông tin kết nối MySQL:
```bash
docker exec -it mysql-service mysql -u app_user -puserpass -e "SELECT 1;"
```

Kiểm tra file SQL được import:
```bash
docker exec -it mysql-service bash -c "ls /docker-entrypoint-initdb.d/"
```

### Lỗi quyền truy cập file

Đặt lại quyền cho thư mục:
```bash
sudo chown -R www-data:www-data ~/QlBanDoAnNhanh/phpCode
sudo chmod -R 755 ~/QlBanDoAnNhanh/phpCode
```

## Lệnh bổ sung

### Dừng containers
```bash
cd ~/QlBanDoAnNhanh/docker
docker compose down
```

### Xem logs chi tiết
```bash
cd ~/QlBanDoAnNhanh/docker
docker compose logs -f
```

### Truy cập container
```bash
# Truy cập container PHP người dùng
docker exec -it php_app bash

# Truy cập container PHP admin
docker exec -it php_admin bash

# Truy cập container MySQL
docker exec -it mysql-service bash
```

### Xóa volumes và rebuild
```bash
cd ~/QlBanDoAnNhanh/docker
docker compose down -v
docker volume rm QlBanDoAnNhanh_mysql_data
docker compose up --build -d
```

