#!/bin/bash

set -e

echo "💫 Cập nhật và khắc phục triệt để triển khai Kubernetes"
echo "-----------------------------------------------------------"

# 1. Kiểm tra trạng thái Minikube và khởi động lại nếu cần
echo "🚀 Kiểm tra và khởi động Minikube..."
minikube_status=$(minikube status | grep host | awk '{print $2}' 2>/dev/null || echo "NotRunning")
if [ "$minikube_status" != "Running" ]; then
    echo "Minikube không chạy, khởi động lại..."
    minikube stop 2>/dev/null || true
    minikube delete --purge 2>/dev/null || true
    minikube start --driver=docker --memory=3072 --cpus=2 --addons=ingress
    # Đảm bảo quyền cho thư mục minikube
    [ -d ~/.minikube ] && chmod -R 755 ~/.minikube
else
    echo "Minikube đã chạy, tiếp tục khắc phục..."
fi

echo "⏳ Đợi Minikube khởi động hoàn tất..."
sleep 10
kubectl cluster-info

# 2. Kiểm tra và dừng tunnel hiện tại nếu đang chạy
echo "🔍 Kiểm tra minikube tunnel hiện tại..."
if pgrep -f "minikube tunnel" > /dev/null; then
    echo "📝 Đang dừng minikube tunnel hiện tại..."
    pkill -f "minikube tunnel" || true
    sleep 5
fi

# 3. Dọn dẹp tài nguyên cũ
echo "🧹 Dọn dẹp tài nguyên cũ..."
kubectl delete --all deployments,statefulsets,services,pods,pvc,pv,configmaps,secrets,jobs,ingress --grace-period=0 --force --ignore-not-found=true

echo "⏳ Đợi tài nguyên xóa hoàn tất..."
sleep 10

# 4. Kiểm tra tài nguyên còn sót lại
echo "🔍 Kiểm tra tài nguyên còn sót lại..."
kubectl get all

# 5. Kiểm tra cấu trúc thư mục phpCode
PHP_CODE_DIR="/home/thinboonny/doannhanh/phpCode"
if [ -d "$PHP_CODE_DIR" ]; then
    echo "📂 Kiểm tra thư mục phpCode..."
    
    # Kiểm tra file index.php
    if [ -f "$PHP_CODE_DIR/index.php" ]; then
        echo "✅ File index.php đã tồn tại"
        
        # Kiểm tra có header UTF-8 không
        if ! grep -q "Content-Type: text/html; charset=UTF-8" "$PHP_CODE_DIR/index.php" && \
           ! grep -q "<meta charset=\"UTF-8\"" "$PHP_CODE_DIR/index.php"; then
            echo "⚠️ File index.php có thể chưa có header UTF-8, thêm vào..."
            
            # Tạo file tạm
            temp_file=$(mktemp)
            
            # Thêm header UTF-8 vào đầu file
            cat > "$temp_file" << EOF
<?php
// Thêm header UTF-8 để hiển thị đúng tiếng Việt
header('Content-Type: text/html; charset=UTF-8');

EOF
            
            # Thêm nội dung cũ vào
            cat "$PHP_CODE_DIR/index.php" >> "$temp_file"
            
            # Thay thế file cũ
            mv "$temp_file" "$PHP_CODE_DIR/index.php"
            echo "✅ Đã thêm header UTF-8 vào index.php"
        fi
    else
        echo "⚠️ Không tìm thấy file index.php trong thư mục phpCode"
    fi
    
    # Kiểm tra file .htaccess
    if [ ! -f "$PHP_CODE_DIR/.htaccess" ]; then
        echo "⚠️ Không tìm thấy file .htaccess, tạo mới..."
        cat > "$PHP_CODE_DIR/.htaccess" << EOF
Options +FollowSymLinks
RewriteEngine On

# Nếu request là file thực tế hoặc thư mục, không rewrite
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
# Rewrite tất cả requests đến index.php
RewriteRule ^(.*)$ index.php [L,QSA]

# Cấu hình charset UTF-8
AddDefaultCharset UTF-8
EOF
        echo "✅ Đã tạo file .htaccess"
    fi
    
    # Đảm bảo quyền đọc/ghi cho các file
    echo "🔧 Thiết lập quyền đọc/ghi cho thư mục phpCode..."
    chmod -R 755 "$PHP_CODE_DIR"
    echo "✅ Đã thiết lập quyền cho thư mục phpCode"
else
    echo "⚠️ Không tìm thấy thư mục phpCode, sẽ được tạo trong quá trình triển khai"
fi

# 6. Chạy lại script triển khai
echo "🔄 Chạy lại script triển khai..."
./k8s/setup_and_repair.sh

# 7. Khởi động tunnel trong nền nếu chưa chạy
echo "�� Kiểm tra và khởi động minikube tunnel..."
if ! pgrep -f "minikube tunnel" > /dev/null; then
    echo "📝 Khởi động minikube tunnel trong nền..."
    nohup minikube tunnel > tunnel.log 2>&1 &
    sleep 5
    
    # Kiểm tra xem tunnel đã khởi động thành công chưa
    if pgrep -f "minikube tunnel" > /dev/null; then
        echo "✅ Minikube tunnel đã được khởi động, log lưu ở tunnel.log"
    else
        echo "⚠️ Không thể khởi động minikube tunnel tự động, vui lòng khởi động thủ công"
        echo "  minikube tunnel"
    fi
else
    echo "✅ Minikube tunnel đã đang chạy"
fi

# 8. Kiểm tra cấu hình UTF-8 trong container
echo "🔍 Kiểm tra cấu hình UTF-8 trong container PHP..."
php_pod=$(kubectl get pods -l app=php-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$php_pod" ]; then
    # Đợi pod khởi động hoàn tất
    echo "⏳ Đợi pod PHP khởi động hoàn tất..."
    kubectl wait --for=condition=Ready pod/$php_pod --timeout=120s
    
    # Kiểm tra cấu hình PHP charset
    echo "🔍 Kiểm tra cấu hình PHP charset..."
    kubectl exec $php_pod -- php -r "echo 'PHP default_charset: ' . ini_get('default_charset') . PHP_EOL;"
    
    # Kiểm tra module Apache
    echo "🔍 Kiểm tra module Apache..."
    kubectl exec $php_pod -- apachectl -M | grep rewrite
    
    # Kiểm tra kết nối MySQL
    echo "🔍 Kiểm tra kết nối MySQL từ container PHP..."
    test_script=$(mktemp)
    cat > "$test_script" << 'EOF'
<?php
$host = 'mysql-service';
$dbname = 'qlbandoannhanh';
$user = 'app_user';
$pass = 'userpassword';

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Kết nối MySQL thành công!\n";
    
    // Thử truy vấn với tiếng Việt
    $stmt = $conn->query("SELECT * FROM categories LIMIT 1");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Dữ liệu UTF-8: " . $row['name'] . " - " . $row['description'] . "\n";
} catch(PDOException $e) {
    echo "Lỗi kết nối MySQL: " . $e->getMessage() . "\n";
}
EOF
    
    kubectl cp "$test_script" "$php_pod:/tmp/test_mysql.php"
    kubectl exec $php_pod -- php /tmp/test_mysql.php
    rm "$test_script"
fi

# 9. Kiểm tra kết nối và hiển thị URL
mysql_pod=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$mysql_pod" ]; then
    echo "🔍 Kiểm tra cấu hình UTF-8 trong MySQL..."
    kubectl exec -it $mysql_pod -- mysql -uroot -prootpassword -e "SHOW VARIABLES LIKE 'character_set%'; SHOW VARIABLES LIKE 'collation%';"
fi

echo "================================================================="
echo "✅ Hoàn tất! Để truy cập ứng dụng PHP, vui lòng thực hiện:"
echo ""
echo "👉 1. Truy cập qua URL:"
minikube service php-service --url
echo ""
echo "👉 2. Hoặc truy cập qua tên miền (sau khi thêm vào /etc/hosts):"
echo "     http://php-app.local"
echo ""
echo "👉 3. Kiểm tra logs PHP pod nếu gặp vấn đề:"
echo "     kubectl logs $php_pod"
echo ""
echo "👉 4. Kiểm tra logs MySQL pod nếu có lỗi kết nối:"
echo "     kubectl logs $mysql_pod"
echo "=================================================================" 