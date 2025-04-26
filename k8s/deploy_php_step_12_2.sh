#!/bin/bash

# 12.2. Lấy tên pod PHP và MySQL


# Đợi và kiểm tra trạng thái PHP Frontend (User) pod với vòng lặp
echo "🔍 12.2 Đợi và kiểm tra trạng thái PHP Frontend (User) pod..."
max_attempts=60  # Tối đa 600 giây (10 phút)
attempt=1
while [ $attempt -le $max_attempts ]; do
  echo "🔍 Kiểm tra trạng thái PHP Frontend (User) pod (lần $attempt/$max_attempts)..."
  kubectl get pods
  php_pod=$(kubectl get pods -l app=php-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
  
  if [ -z "$php_pod" ]; then
    echo "⚠️ PHP Frontend (User) pod chưa được tạo."
    sleep 10
    attempt=$((attempt + 1))
    continue
  fi
  
  php_status=$(kubectl get pod $php_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
  php_ready=$(kubectl get pod $php_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
  
  if [ "$php_status" = "CrashLoopBackOff" ] || [ "$php_status" = "Error" ]; then
    echo "❌ PHP Frontend (User) pod gặp lỗi nghiêm trọng (Trạng thái: $php_status)."
    echo "📝 Chi tiết pod:"
    kubectl describe pod $php_pod
    echo "📝 Log pod:"
    kubectl logs $php_pod 2>/dev/null || echo "Không có log (pod chưa chạy)."
    exit 1
  fi
  
  if [ "$php_status" != "Running" ]; then
    echo "⚠️ PHP Frontend (User) pod chưa ở trạng thái Running (Trạng thái: $php_status)."
  elif [ "$php_ready" != "true" ]; then
    echo "⚠️ PHP Frontend (User) pod chưa sẵn sàng (Trạng thái: $php_status, Ready: $php_ready)."
  else
    echo "✅ PHP Frontend (User) pod đã sẵn sàng!"
    # Lưu tên pod để dùng sau
    echo $php_pod > /tmp/php_pod_name.txt
    break
  fi
  
  if [ $attempt -eq $max_attempts ]; then
    echo "❌ Hết thời gian chờ, PHP Frontend (User) pod không sẵn sàng:"
    echo "📝 Chi tiết pod:"
    kubectl describe pod $php_pod
    echo "📝 Log pod:"
    kubectl logs $php_pod 2>/dev/null || echo "Không có log (pod chưa chạy)."
    exit 1
  fi
  
  sleep 10
  attempt=$((attempt + 1))
done

# Đợi và kiểm tra trạng thái PHP Admin pod với vòng lặp
echo "🔍 Đợi và kiểm tra trạng thái PHP Admin pod..."
max_attempts=60  # Tối đa 600 giây (10 phút)
attempt=1
while [ $attempt -le $max_attempts ]; do
  echo "🔍 Kiểm tra trạng thái PHP Admin pod (lần $attempt/$max_attempts)..."
  kubectl get pods
  php_admin_pod=$(kubectl get pods -l app=php-admin -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
  
  if [ -z "$php_admin_pod" ]; then
    echo "⚠️ PHP Admin pod chưa được tạo."
    sleep 10
    attempt=$((attempt + 1))
    continue
  fi
  
  php_admin_status=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotRunning")
  php_admin_ready=$(kubectl get pod $php_admin_pod -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
  
  if [ "$php_admin_status" = "CrashLoopBackOff" ] || [ "$php_admin_status" = "Error" ]; then
    echo "❌ PHP Admin pod gặp lỗi nghiêm trọng (Trạng thái: $php_admin_status)."
    echo "📝 Chi tiết pod:"
    kubectl describe pod $php_admin_pod
    echo "📝 Log pod:"
    kubectl logs $php_admin_pod 2>/dev/null || echo "Không có log (pod chưa chạy)."
    exit 1
  fi
  
  if [ "$php_admin_status" != "Running" ]; then
    echo "⚠️ PHP Admin pod chưa ở trạng thái Running (Trạng thái: $php_admin_status)."
  elif [ "$php_admin_ready" != "true" ]; then
    echo "⚠️ PHP Admin pod chưa sẵn sàng (Trạng thái: $php_admin_status, Ready: $php_admin_ready)."
  else
    echo "✅ PHP Admin pod đã sẵn sàng!"
    # Lưu tên pod để dùng sau
    echo $php_admin_pod > /tmp/php_admin_pod_name.txt
    break
  fi
  
  if [ $attempt -eq $max_attempts ]; then
    echo "❌ Hết thời gian chờ, PHP Admin pod không sẵn sàng:"
    echo "📝 Chi tiết pod:"
    kubectl describe pod $php_admin_pod
    echo "📝 Log pod:"
    kubectl logs $php_admin_pod 2>/dev/null || echo "Không có log (pod chưa chạy)."
    exit 1
  fi
  
  sleep 10
  attempt=$((attempt + 1))
done

# Tạo Ingress cho cả PHP Frontend và PHP Admin (nếu dùng domain)
echo "🚀 Tạo Ingress cho PHP Frontend (User) và Admin..."
cat > app-ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx  # Đảm bảo đã cài Ingress Controller (như nginx-ingress)
  rules:
  - host: frontend.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: php-app-service
            port:
              number: 80
  - host: admin.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: php-admin-service
            port:
              number: 80
EOF
kubectl apply -f app-ingress.yaml -n default || {
  echo "❌ Không thể áp dụng Ingress."
  exit 1
}
rm -f app-ingress.yaml