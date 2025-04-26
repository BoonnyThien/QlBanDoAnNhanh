#!/bin/bash

echo "🔍 Bắt đầu quét bảo mật container images..."

# Danh sách các images cần quét
IMAGES=(
    "buithienboo/qlbandoannhanh-php-app:1.1"  # php-app
    "buithienboo/qlbandoannhanh-php-app:1.1"  # php-admin (cùng image)
    "mysql:8.0"                               # mysql
)

# Đường dẫn cài đặt trivy
TRIVY_INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$TRIVY_INSTALL_DIR"
export PATH="$TRIVY_INSTALL_DIR:$PATH"

# Kiểm tra và cài đặt trivy
if ! command -v trivy &> /dev/null; then
    echo "❌ Trivy chưa được cài đặt. Đang cài đặt vào $TRIVY_INSTALL_DIR..."
    if ! curl -sfL --connect-timeout 30 https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b "$TRIVY_INSTALL_DIR" latest; then
        echo "❌ Lỗi: Không thể cài đặt trivy. Vui lòng kiểm tra kết nối mạng hoặc quyền truy cập."
        exit 1
    fi
fi

# Kiểm tra lại trivy
if ! command -v trivy &> /dev/null; then
    echo "❌ Lỗi: Trivy vẫn chưa được cài đặt. Vui lòng kiểm tra thủ công."
    exit 1
fi

# Quét từng image và lưu kết quả
for image in "${IMAGES[@]}"; do
    echo "🔍 Đang quét image: $image"
    output_file="scan-$(echo $image | tr '/' '-' | tr ':' '-').txt"
    if trivy image --severity HIGH,CRITICAL "$image" > "$output_file" 2>&1; then
        echo "✅ Kết quả quét $image được lưu vào $output_file"
        cat "$output_file" | grep -E "Total:.*(HIGH|CRITICAL)"
    else
        echo "⚠️ Lỗi khi quét image $image. Vui lòng kiểm tra image có tồn tại không."
        cat "$output_file"
    fi
done

echo "✅ Hoàn tất quét bảo mật container images!"