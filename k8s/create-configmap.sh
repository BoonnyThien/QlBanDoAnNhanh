#!/bin/bash

# Xóa ConfigMap cũ nếu tồn tại
kubectl delete configmap php-code --ignore-not-found

# Tạo ConfigMap từ thư mục phpCode
kubectl create configmap php-code \
  --from-file=phpCode/index.php \
  --from-file=phpCode/shop.php \
  --from-file=phpCode/sign-in.php \
  --from-file=phpCode/sign-up.php \
  --from-file=phpCode/admin/config/config.php \
  --from-file=phpCode/pages/navtop.php \
  --from-file=phpCode/pages/navmenu.php \
  --from-file=phpCode/pages/main.php \
  --from-file=phpCode/pages/footer.php

# Hiển thị thông tin ConfigMap
kubectl describe configmap php-code 