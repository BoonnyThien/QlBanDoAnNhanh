#!/bin/bash

# 12.5. Kích hoạt extension và cấu hình Apache
echo "🚀 [12.5] Kích hoạt extension và cấu hình Apache..."

# Đọc tên pod từ file tạm
php_pod=$(cat /tmp/php_pod_name.txt)
if [ -z "$php_pod" ]; then
  echo "❌ Không tìm thấy tên pod PHP. Vui lòng chạy bước 12.1 trước."
  exit 1
fi

# Kích hoạt extension thủ công
echo "🔍 Kích hoạt extension PHP thủ công..."
kubectl exec $php_pod --container php -- bash -c "sudo sh -c 'echo \"extension=pdo.so\" > /usr/local/etc/php/conf.d/docker-php-ext-pdo.ini'" || {
  echo "❌ Không thể kích hoạt extension PDO."
  echo "🔍 Kiểm tra file .ini trong conf.d:"
  kubectl exec $php_pod --container php -- ls -l /usr/local/etc/php/conf.d
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}
kubectl exec $php_pod --container php -- bash -c "sudo sh -c 'echo \"extension=pdo_mysql.so\" > /usr/local/etc/php/conf.d/docker-php-ext-pdo_mysql.ini'" || {
  echo "❌ Không thể kích hoạt extension PDO-MySQL."
  echo "🔍 Kiểm tra file .ini trong conf.d:"
  kubectl exec $php_pod --container php -- ls -l /usr/local/etc/php/conf.d
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Kiểm tra xem extension đã được tải chưa
echo "🔍 Kiểm tra extension PHP đã được tải..."
kubectl exec $php_pod --container php -- php -m | grep -E "pdo|pdo_mysql" || {
  echo "❌ Extension PDO hoặc PDO-MySQL không được tải."
  echo "🔍 Kiểm tra danh sách module PHP:"
  kubectl exec $php_pod --container php -- php -m
  echo "🔍 Kiểm tra file .ini trong conf.d:"
  kubectl exec $php_pod --container php -- ls -l /usr/local/etc/php/conf.d
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

# Đảm bảo Apache hỗ trợ .htaccess và cấu hình ServerName
echo "🔍 Cấu hình Apache để hỗ trợ .htaccess và ServerName..."
kubectl exec $php_pod --container php -- bash -c "sudo sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf && echo 'ServerName localhost' | sudo tee -a /etc/apache2/apache2.conf" || {
  echo "❌ Không thể cấu hình Apache để hỗ trợ .htaccess hoặc ServerName."
  echo "🔍 Kiểm tra file cấu hình Apache:"
  kubectl exec $php_pod --container php -- cat /etc/apache2/apache2.conf
  echo "🔍 Log của pod PHP:"
  kubectl logs $php_pod
  exit 1
}

echo "✅ [12.5] Kích hoạt extension và cấu hình Apache hoàn tất."