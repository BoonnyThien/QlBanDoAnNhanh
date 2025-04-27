# Hướng dẫn Thiết lập Bảo mật cho Hệ thống Quản lý Bán Đồ Ăn Nhanh trên Kubernetes

## Giới thiệu
Dự án **Quản lý Bán Đồ Ăn Nhanh (QlBanDoAnNhanh)** triển khai một hệ thống web trên Kubernetes với các biện pháp bảo mật toàn diện để đảm bảo an toàn dữ liệu, truy cập, và vận hành. Script `deploy-security.sh` và `check-security.sh` được sử dụng để thiết lập và kiểm tra các lớp bảo mật, bao gồm quản lý quyền truy cập, kiểm soát mạng, mã hóa, giám sát, và sao lưu. Hệ thống này thể hiện năng lực tích hợp các công nghệ bảo mật hiện đại, phù hợp cho các ứng dụng thương mại điện tử yêu cầu độ tin cậy cao.

## Công nghệ sử dụng
- **RBAC (Role-Based Access Control)**: Quản lý quyền truy cập trong Kubernetes, đảm bảo các thành phần như PHP và MySQL chỉ có quyền tối thiểu cần thiết.
- **Network Policies**: Kiểm soát lưu lượng mạng, giới hạn kết nối giữa các pod (ví dụ: chỉ cho phép PHP truy cập MySQL qua cổng 3306).
- **Secrets**: Lưu trữ thông tin nhạy cảm (mật khẩu, khóa ứng dụng, thông tin Cloudflare) dưới dạng mã hóa base64.
- **TLS Certificates**: Mã hóa kết nối HTTPS cho Frontend và Admin, sử dụng chứng chỉ tự ký.
- **Container Security Scanning**: Quét lỗ hổng bảo mật trong Docker images (`buithienboo/qlbandoannhanh-php-app:1.1`, `mysql:8.0`) để phát hiện và giảm thiểu rủi ro.
- **MySQL Hardening**: Tăng cường bảo mật MySQL bằng cấu hình bảo mật (`mysql-security-config`) và giới hạn kết nối.
- **Auth Service**: Dịch vụ xác thực riêng, sử dụng JWT để bảo vệ API và xác minh danh tính người dùng.
- **Prometheus và Grafana**: Giám sát hiệu suất và trạng thái của hệ thống, với ServiceMonitors theo dõi PHP và MySQL.
- **Velero**: Sao lưu và khôi phục tài nguyên Kubernetes, đảm bảo khả năng phục hồi sau sự cố.
- **Falco**: Phát hiện và cảnh báo các hoạt động bất thường trong cụm Kubernetes (ví dụ: truy cập trái phép).
- **Helm**: Công cụ quản lý chart Kubernetes, dùng để cài đặt Prometheus Operator.
- **Cloudflare Tunnel**: Bảo vệ kết nối từ cụm Minikube ra Internet, sử dụng thông tin xác thực mã hóa.

## Ứng dụng thực tiễn
- **Người dùng cuối**: Truy cập hệ thống an toàn qua HTTPS, với dữ liệu được mã hóa và xác thực qua Auth Service.
- **Quản trị viên**: Quản lý hệ thống qua giao diện Admin được bảo vệ bằng TLS và Network Policies.
- **Nhà phát triển/DevOps**: Học cách triển khai bảo mật Kubernetes, từ RBAC, Network Policies đến giám sát và sao lưu.
- **Nhà tuyển dụng**: Đánh giá năng lực tích hợp các công nghệ bảo mật (RBAC, TLS, Velero, Falco) và khả năng tự động hóa kiểm tra bảo mật (`deploy-security.sh`, `check-security.sh`).

## Yêu cầu hệ thống
- Minikube
- Kubernetes (kubectl)
- Docker Engine 20.10+
- Helm
- Velero CLI
- Falco
- Cloudflare Tunnel CLI (`cloudflared`)
- Trivy (cho quét bảo mật container)

## Các bước thiết lập bảo mật

### 1. Clone repository
```bash
git clone https://github.com/BoonnyThien/QlBanDoAnNhanh.git
cd QlBanDoAnNhanh
```

### 2. Chuẩn bị môi trường
- Đảm bảo Minikube, kubectl, Helm, Velero, Falco, và Trivy đã được cài đặt.
- Đảm bảo hệ thống chính đã được triển khai bằng script `k8s/setup_and_repair.sh`.
- Đảm bảo thư mục `k8s/security/` chứa script `deploy-security.sh` và `check-security.sh`.

### 3. Chạy script thiết lập bảo mật
```bash
cd ~/QlBanDoAnNhanh/k8s/security
chmod +x deploy-security.sh
./deploy-security.sh
```

### 4. Kiểm tra bảo mật
```bash
cd ~/QlBanDoAnNhanh/k8s/security
chmod +x check-security.sh
./check-security.sh
```

### 5. Kiểm tra trạng thái bảo mật
```bash
# Kiểm tra ServiceAccounts, Roles, RoleBindings
kubectl get serviceaccount
kubectl get role
kubectl get rolebinding

# Kiểm tra Network Policies
kubectl get networkpolicy

# Kiểm tra Secrets
kubectl get secret

# Kiểm tra TLS certificates
kubectl get secret tls-secret -o yaml
kubectl get secret app-tls -o yaml

# Kiểm tra ServiceMonitors
kubectl get servicemonitor

# Kiểm tra Velero backups
velero backup get

# Kiểm tra Falco pods
kubectl get pods -n falco
```

## Xử lý sự cố thường gặp

### Lỗi RBAC

Kiểm tra ServiceAccounts và RoleBindings:
```bash
kubectl get serviceaccount
kubectl get rolebinding -o yaml
```

Xóa và áp dụng lại RBAC:
```bash
cd ~/QlBanDoAnNhanh/k8s/security
kubectl delete -f rbac.yaml
./deploy-security.sh
```

### Lỗi Network Policies

Kiểm tra Network Policies:
```bash
kubectl describe networkpolicy
```

Xóa và áp dụng lại:
```bash
kubectl delete networkpolicy --all
cd ~/QlBanDoAnNhanh/k8s/security
./deploy-security.sh
```

### Lỗi Secrets

Kiểm tra Secrets:
```bash
kubectl get secret mysql-secrets -o yaml
kubectl get secret php-app-secrets -o yaml
```

Tạo lại Secrets:
```bash
kubectl delete secret mysql-secrets php-app-secrets php-admin-secrets cloudflare-secrets
cd ~/QlBanDoAnNhanh/k8s/security
./deploy-security.sh
```

### Lỗi TLS Certificates

Kiểm tra TLS Secrets:
```bash
kubectl get secret tls-secret -o yaml
kubectl get secret app-tls -o yaml
```

Tạo lại chứng chỉ:
```bash
kubectl delete secret tls-secret app-tls admin-tls
cd ~/QlBanDoAnNhanh/k8s/security
./deploy-security.sh
```

### Lỗi MySQL Hardening

Kiểm tra ConfigMap bảo mật:
```bash
kubectl get configmap mysql-security-config -o yaml
```

Kiểm tra logs MySQL:
```bash
kubectl logs -l app=mysql
```

Áp dụng lại cấu hình:
```bash
kubectl delete configmap mysql-security-config
cd ~/QlBanDoAnNhanh/k8s/security
./deploy-security.sh
```

### Lỗi Auth Service

Kiểm tra pod và logs:
```bash
kubectl get pods -l app=auth-service
kubectl logs -l app=auth-service
```

Khởi động lại Auth Service:
```bash
kubectl delete pod -l app=auth-service
```

### Lỗi Monitoring (Prometheus/Grafana)

Kiểm tra ServiceMonitors và pods:
```bash
kubectl get servicemonitor
kubectl get pods -l app.kubernetes.io/name=prometheus
```

Cài lại Prometheus Operator:
```bash
helm uninstall prometheus-operator
cd ~/QlBanDoAnNhanh/k8s/security
./deploy-security.sh
```

### Lỗi Velero Backup

Kiểm tra Velero pods và backups:
```bash
kubectl get pods -n velero
velero backup get
```

Tạo lại backup:
```bash
velero backup delete qlbandoannhanh-backup
cd ~/QlBanDoAnNhanh/k8s/security
./deploy-security.sh
```

### Lỗi Falco

Kiểm tra Falco pods và logs:
```bash
kubectl get pods -n falco
kubectl logs -n falco -l app=falco
```

Cài lại Falco:
```bash
kubectl delete -n falco daemonset falco
cd ~/QlBanDoAnNhanh/k8s/security
./deploy-security.sh
```

## Lệnh bổ sung

### Xóa tài nguyên bảo mật
```bash
cd ~/QlBanDoAnNhanh/k8s/security
kubectl delete -f .
helm uninstall prometheus-operator
kubectl delete -n falco daemonset falco
kubectl delete -n velero deployment velero
```

### Truy cập pod
```bash
# Truy cập Auth Service pod
kubectl exec -it $(kubectl get pod -l app=auth-service -o jsonpath="{.items[0].metadata.name}") -- bash

# Truy cập Falco pod
kubectl exec -it -n falco $(kubectl get pod -n falco -l app=falco -o jsonpath="{.items[0].metadata.name}") -- bash

# Truy cập Velero pod
kubectl exec -it -n velero $(kubectl get pod -n velero -l app.kubernetes.io/name=velero -o jsonpath="{.items[0].metadata.name}") -- bash
```

### Kiểm tra chi tiết
```bash
# Kiểm tra container scan results
cat scan-buithienboo-qlbandoannhanh-php-app-1.1.txt
cat scan-mysql-8.0.txt

# Kiểm tra Prometheus Operator
kubectl get pods -l app.kubernetes.io/name=prometheus

# Kiểm tra Velero backup logs
velero backup logs qlbandoannhanh-backup

# Kiểm tra Falco events
kubectl logs -n falco -l app=falco
```

## Thành phần chính và cách hoạt động

### Script deploy-security.sh:
- **RBAC**: Tạo ServiceAccounts (php-app-sa, php-admin-sa, mysql-sa), Roles, và RoleBindings để giới hạn quyền truy cập.
- **Network Policies**: Tạo các chính sách mạng (allow-php-to-mysql, allow-http-ingress-php-app, allow-http-ingress-php-admin, allow-auth-service) để kiểm soát lưu lượng.
- **Secrets**: Tạo Secrets (mysql-secrets, php-app-secrets, php-admin-secrets, cloudflare-secrets) chứa thông tin mã hóa base64.
- **Container Scanning**: Sử dụng Trivy để quét lỗ hổng trong images (buithienboo/qlbandoannhanh-php-app:1.1, mysql:8.0).
- **TLS Certificates**: Tạo chứng chỉ tự ký (tls-secret, app-tls, admin-tls) cho HTTPS.
- **MySQL Hardening**: Áp dụng ConfigMap mysql-security-config để cấu hình bảo mật MySQL.
- **Auth Service**: Triển khai pod và service (auth-service) để xác thực JWT.
- **Monitoring**: Cài Prometheus Operator qua Helm, tạo ServiceMonitors cho PHP và Admin.
- **Velero**: Cài đặt Velero và tạo backup cho namespace default (qlbandoannhanh-backup).
- **Falco**: Triển khai DaemonSet để giám sát hành vi bất thường trong cụm.

### Script check-security.sh:
- Kiểm tra trạng thái Minikube và pods.
- Kiểm tra RBAC (ServiceAccounts, Roles, RoleBindings) và quyền của từng ServiceAccount.
- Kiểm tra Network Policies và chi tiết cấu hình.
- Kiểm tra Secrets và giá trị mã hóa (DB_HOST, MYSQL_ROOT_PASSWORD).
- Kiểm tra container security qua kết quả quét Trivy.
- Kiểm tra TLS certificates (thời hạn, trạng thái).
- Kiểm tra MySQL hardening (SSL, giới hạn kết nối, slow query log).
- Kiểm tra Auth Service (pod, service, logs, JWT_SECRET).
- Kiểm tra monitoring (ServiceMonitors, Prometheus pods).
- Kiểm tra Velero backups và khả năng khôi phục.
- Kiểm tra Falco pods và logs sự kiện bất thường.

### RBAC:
- ServiceAccounts được gán Roles cụ thể, đảm bảo PHP chỉ truy cập tài nguyên liên quan và MySQL chỉ xử lý database.

### Network Policies:
- Giới hạn lưu lượng đến MySQL (cổng 3306) từ PHP pods.
- Cho phép HTTP vào PHP Frontend (cổng 8080) và Admin (cổng 8081) từ IP Cloudflare.
- Cho phép Auth Service nhận kết nối từ PHP pods.

### Secrets:
- Lưu trữ thông tin nhạy cảm như mật khẩu MySQL, khóa ứng dụng, và thông tin Cloudflare Tunnel.

### TLS Certificates:
- Chứng chỉ tự ký cho app.yourdomain.com và admin.yourdomain.com, đảm bảo kết nối HTTPS.

### Container Security:
- Quét images phát hiện 104 lỗ hổng cho PHP image (2 CRITICAL) và 34 cho MySQL (3 CRITICAL).

### MySQL Hardening:
- ConfigMap mysql-security-config áp dụng các cấu hình bảo mật (giới hạn kết nối, bật SSL).

### Auth Service:
- Chạy trên cổng 8080, sử dụng JWT_SECRET để xác thực yêu cầu.

### Monitoring:
- Prometheus và Grafana giám sát hiệu suất PHP và MySQL qua ServiceMonitors.

### Velero:
- Sao lưu toàn bộ namespace default, lưu trữ dữ liệu MySQL và cấu hình Kubernetes.

### Falco:
- Phát hiện hành vi bất thường (ví dụ: lỗi kernel headers trong WSL2), nhưng gặp vấn đề CrashLoopBackOff do cấu hình kernel.

## Các file bảo mật bổ sung trong thư mục k8s/security

Dự án còn bao gồm nhiều file bảo mật bổ sung trong thư mục `k8s/security/`:

- **RBAC**: `rbac.yaml` - Cấu hình quyền truy cập cho các thành phần
- **Network Policies**: `network-policies.yaml` - Cấu hình chính sách mạng
- **Secrets**: `secrets.yaml` - Cấu hình thông tin nhạy cảm
- **Auth Service**: `auth-service.yaml` và thư mục `auth-service/` - Cấu hình dịch vụ xác thực
- **Falco**: `falco.yaml` - Cấu hình giám sát bảo mật
- **Velero**: `velero-backup.yaml` và `velero-credentials` - Cấu hình sao lưu
- **Audit Policy**: `audit-policy.yaml` - Cấu hình kiểm toán
- **Key Rotation**: `key-rotation-cronjob.yaml` - Cấu hình luân chuyển khóa tự động
- **Scripts**: Thư mục `scripts/` - Các script bổ sung cho bảo mật

## Truy cập và sử dụng

- **Frontend**: Truy cập qua HTTPS với chứng chỉ TLS, xác thực qua Auth Service.
- **Admin**: Quản lý hệ thống qua HTTPS, bảo vệ bằng Network Policies và RBAC.
- **Monitoring**: Truy cập Grafana để xem số liệu hiệu suất (yêu cầu cấu hình thêm port-forward).
- **Backup**: Sử dụng Velero để khôi phục hệ thống khi cần:
```bash
velero restore create --from-backup qlbandoannhanh-backup
```

## Lưu ý

### Một số vấn đề phát hiện trong check-security.sh:
- MySQL pod (mysql-7f586ff5ff-m62nz) ở trạng thái CrashLoopBackOff.
- Falco pod (falco-7ftv4) gặp lỗi kernel headers, cần cài đặt linux-headers hoặc điều chỉnh cấu hình.
- Velero backup doannhanh-backup không tồn tại, cần kiểm tra cấu hình lưu trữ.
- Prometheus service không tìm thấy, cần kiểm tra namespace hoặc cấu hình Helm.

### Đề xuất cải thiện:
- Sửa lỗi kernel headers cho Falco.
- Cập nhật images để giảm lỗ hổng CRITICAL.
- Cấu hình Velero với backend lưu trữ (ví dụ: AWS S3).
- Kích hoạt slow query log cho MySQL để tối ưu hóa hiệu suất.