#!/bin/bash

# Màu cho terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # reset màu

# Kiểm tra xem font đã được cài chưa
if fc-list | grep -qi "NotoColorEmoji"; then
    echo -e "${GREEN}✅ fonts-noto-color-emoji đã được cài trước đó. Không cần cài lại.${NC}"
else
    echo -e "${YELLOW}📦 Đang cài đặt fonts-noto-color-emoji...${NC}"
    sudo apt update
    sudo apt install -y fonts-noto-color-emoji
    echo -e "${GREEN}✅ Cài đặt hoàn tất.${NC}"
fi

# Kiểm tra hiển thị emoji
echo -e "\n🔍 Kiểm tra hiển thị emoji:"
echo -e "✅ 🛢️ 🔄 🔧 ⏳ ❌ 🚀"
