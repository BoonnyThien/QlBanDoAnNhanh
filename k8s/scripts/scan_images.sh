#!/bin/bash

echo "🔍 Bắt đầu quét bảo mật container images..."

# Danh sách các images cần quét
IMAGES=(
    "buithienboo/qlbandoannhanh-php-app:1.1"
    "mysql:8.0"
)

# Kiểm tra xem trivy đã được cài đặt chưa
if ! command -v trivy &> /dev/null; then
    echo "❌ Trivy chưa được cài đặt. Đang cài đặt..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.18.3
fi

# Quét từng image
for image in "${IMAGES[@]}"; do
    echo "🔍 Đang quét image: $image"
    trivy image --severity HIGH,CRITICAL "$image"
done

echo "✅ Hoàn tất quét bảo mật container images!"