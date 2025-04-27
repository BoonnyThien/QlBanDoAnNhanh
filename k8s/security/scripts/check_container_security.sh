echo "🚀 5 Kiểm tra Container Security..."
echo "🔹 Pods:"
kubectl get pods -o wide -n default
echo "🔹 Images đã sử dụng:"
kubectl get pods -n default -o jsonpath="{.items[*].spec.containers[*].image}" | tr -s ' ' '\n' | sort | uniq
echo "🔹 Kết quả quét bảo mật:"
for file in scan-*.txt; do
  if [ -f "$file" ]; then
    echo "📄 $file:"
    cat "$file" | grep -E "Total:.*(HIGH|CRITICAL)"
  fi
done
echo ""