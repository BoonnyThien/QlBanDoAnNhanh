Hướng dẫn Bảo mật Hệ thống QLBandoannhanh
Tổng quan
Tài liệu này mô tả các biện pháp bảo mật được triển khai trong hệ thống QLBandoannhanh - một ứng dụng web PHP bán đồ ăn nhanh, bao gồm các thành phần chính:

php-app: Frontend và backend của ứng dụng.
mysql: Database lưu trữ dữ liệu đơn hàng và thông tin khách hàng.

Hệ thống được triển khai trên Kubernetes (sử dụng Minikube để phát triển và thử nghiệm).
Chuẩn bị Môi trường
Trước khi triển khai bảo mật, cần chuẩn bị môi trường như sau:

Khởi động Minikube:
```bash
minikube start --driver=docker --memory=3072 --cpus=2 --addons=ingress
```
Kiểm tra kết nối Kubernetes:
```bash
kubectl cluster-info
```
Cấp quyền thực thi cho các script:
```bash
chmod +x k8s/security/scripts/*.sh
chmod +x k8s/security/deploy-security.sh
```

Build image cho auth-service (nếu chưa build):
```bash
cd k8s/security/auth-service
docker build -t buithienboo/auth-service:1.0 .
docker push buithienboo/auth-service:1.0
```

Các Biện Pháp Bảo Mật
1. Bảo vệ Truy cập (RBAC)
Mục đích

-  Tạo ServiceAccount, Role, và RoleBinding để giới hạn quyền của php-app và mysql.
-  Ngăn chặn lạm quyền (ví dụ: php-app không thể xóa pod hoặc truy cập tài nguyên không được phép).
-  Tăng tính bảo mật cho ứng dụng.

2. Kiểm Soát Giao Tiếp (Network Policies)
Mục đích

-  Chỉ cho phép php-app truy cập mysql qua cổng 3306.
-  Giới hạn truy cập HTTP từ IP nội bộ (dải 192.168.0.0/16).
-  Bảo vệ database khỏi truy cập trái phép.
-  Giảm nguy cơ tấn công từ bên ngoài vào ứng dụng.

3. Bảo Vệ Thông Tin Nhạy Cảm (Secrets)
Mục đích

-  Lưu trữ mật khẩu MySQL và API key trong Kubernetes Secrets.
-  Ngăn chặn việc hardcode thông tin nhạy cảm trong mã nguồn.
-  Giảm rủi ro lộ thông tin nếu mã nguồn bị truy cập.

4. Kiểm Tra Bảo Mật Container (Scan Images)
Mục đích

-  Quét lỗ hổng trong image của php-app và mysql bằng trivy.
-  Đảm bảo không triển khai image có lỗ hổng nghiêm trọng.
-  Giảm nguy cơ bị khai thác qua container.

5. Bảo Mật Kết Nối (TLS Certificates)
Mục đích

-  Tạo chứng chỉ TLS tự ký để mã hóa kết nối.
-  Bảo vệ dữ liệu truyền tải (giữa client và php-app).
-  Giảm nguy cơ bị nghe lén hoặc tấn công man-in-the-middle.

6. Tăng Cường Bảo Mật MySQL (Hardening MySQL)
Mục đích

-  Áp dụng cấu hình bảo mật cho MySQL (bật SSL, giới hạn kết nối, logging).
-  Bảo vệ database khỏi truy cập trái phép.
-  Phát hiện các truy vấn chậm (có thể là dấu hiệu tấn công).

7. Xác Thực API (Auth-Service)
Mục đích

-  Triển khai auth-service để xử lý xác thực JWT.
-  Đảm bảo chỉ người dùng hợp lệ (có token hợp lệ) mới truy cập được API.
-  Tăng bảo mật cho các endpoint của ứng dụng.

8. Giám Sát Hệ Thống (Monitoring)
Mục đích

-  Triển khai Prometheus để giám sát metrics của hệ thống (CPU, memory, HTTP requests).
-  Phát hiện kịp thời các vấn đề (CPU/memory cao, lỗi HTTP).
-  Giúp duy trì hoạt động ổn định của ứng dụng.

9. Backup Dữ Liệu (Velero)
Mục đích

-  Triển khai Velero để backup pod và PVC của mysql.
-  Bảo vệ dữ liệu đơn hàng, thông tin khách hàng khỏi mất mát.
-  Hỗ trợ khôi phục nhanh nếu có sự cố.

10. Phát Hiện Xâm Nhập (Falco)
Mục đích

-  Triển khai Falco để giám sát hành vi bất thường trong runtime.
-  Phát hiện các hành vi đáng ngờ (ví dụ: container chạy lệnh không được phép).
-  Tăng khả năng phát hiện tấn công.

11. Ghi Lại Sự Kiện (Audit Logging)
Mục đích

-  Thiết lập audit logging để ghi lại các sự kiện trong Kubernetes.
-  Giúp truy vết nếu có sự cố bảo mật (ví dụ: ai đã xóa pod, ai truy cập secrets).
-  Theo dõi hoạt động của người dùng và hệ thống.

12. Xoay Vòng Khóa (Rotation Keys)
Mục đích

-  Cập nhật định kỳ mật khẩu trong Secrets.
-  Giảm nguy cơ lộ mật khẩu nếu bị tấn công.
-  Tăng cường bảo mật dài hạn.

Script Triển Khai
Chạy script sau để triển khai các biện pháp bảo mật:
```bash
cd ~/doannhanh
./k8s/security/deploy-security.sh
```
Kiểm Tra Bảo Mật
```bash
chmod +x k8s/security/check-security.sh
./k8s/security/check-security.sh
```
Tổng Quan Hệ Thống
# Kiểm tra trạng thái Minikube
```bash
minikube status

# Kiểm tra pod của ứng dụng chính
kubectl get pods -n default -l app=php-app
kubectl get pods -n default -l app=mysql
```
1. Kiểm Tra RBAC
```bash
kubectl get serviceaccounts -n default
kubectl get roles -n default
kubectl get rolebindings -n default
kubectl auth can-i --as system:serviceaccount:default:php-app-sa get pods
```
2. Kiểm Tra Network Policies
```bash
kubectl describe networkpolicies -n default
```
3. Kiểm Tra Secrets
```bash
kubectl get secrets -n default
```
4. Kiểm Tra Container Security
```bash
# Kiểm tra pod
kubectl get pods -o wide -n default

# Kiểm tra image đã sử dụng
kubectl get pods -n default -o jsonpath="{.items[*].spec.containers[*].image}" | tr -s ' ' '\n' | sort | uniq
```
5. Kiểm Tra TLS Certificates
```bash
# Kiểm tra secret chứa chứng chỉ TLS
kubectl get secrets tls-secret -n default
```
6. Kiểm Tra MySQL Hardening
```bash
# Kiểm tra pod của mysql
MYSQL_POD=$(kubectl get pods -n default -l app=mysql -o name | head -n 1)
kubectl exec -it $MYSQL_POD -- mysql -u root -prootpass -e "SHOW VARIABLES LIKE '%ssl%'"
kubectl exec -it $MYSQL_POD -- mysql -u root -prootpass -e "SHOW VARIABLES LIKE 'max_connections'"
```
7. Kiểm Tra Auth Service
```bash
kubectl get pods -n default -l app=auth-service
kubectl logs -n default -l app=auth-service
```
8. Kiểm Tra Monitoring
```bash
kubectl get servicemonitors -n default
kubectl get pods -n default -l app=prometheus
```
9. Kiểm Tra Backup
```bash
velero backup get
velero backup describe mysql-backup
kubectl get pods -n velero
```
10. Kiểm Tra Falco
```bash
kubectl get pods -n falco -l app=falco
kubectl logs -n falco -l app=falco
```
11. Kiểm Tra Audit Logs
```bash
# Truy cập Minikube để xem audit logs
minikube ssh
sudo cat /var/log/kubernetes/audit.log
exit
```
12. Kiểm Tra Key Rotation
```bash
# Kiểm tra giá trị MYSQL_PASSWORD trong mysql-secrets
kubectl get secret mysql-secrets -n default -o jsonpath="{.data.MYSQL_PASSWORD}" | base64 -d
```
Lưu Ý Quan Trọng

Cập nhật Secrets định kỳ:
Cập nhật mật khẩu trong Secrets mỗi 90 ngày bằng cách chạy lại deploy-security.sh hoặc tạo CronJob để tự động hóa.


Quét bảo mật container thường xuyên:
Chạy scan_images.sh mỗi tuần để kiểm tra lỗ hổng mới:
```bash
./k8s/security/scripts/scan_images.sh
```
Kiểm tra logs bảo mật hàng ngày:
Xem logs của Falco để phát hiện hành vi bất thường:
```bash
kubectl logs -n falco -l app=falco
```
Backup dữ liệu định kỳ:
Tạo backup hàng ngày bằng Velero:
```bash
velero backup create daily-mysql-backup --include-resources pods,pvc --selector app=mysql
```
Cập nhật patches bảo mật kịp thời:
Cập nhật image php-app, mysql, và các công cụ (Prometheus, Falco, Velero) khi có bản vá bảo mật.

Giám sát các cảnh báo từ Falco:
Thiết lập cảnh báo (ví dụ: tích hợp Falco với Slack hoặc email) để nhận thông báo khi có sự cố.

Kiểm tra audit logs định kỳ:
Xem audit logs hàng tuần để phát hiện hành vi bất thường:
```bash
minikube ssh "sudo cat /var/log/kubernetes/audit.log"
```
Đảm bảo network policies được áp dụng đúng:
Kiểm tra lại Network Policies sau mỗi lần triển khai mới:
```bash
kubectl describe networkpolicies -n default
```
Kiểm tra chứng chỉ TLS định kỳ:
Xem thời hạn chứng chỉ TLS mỗi 30 ngày:
```bash
kubectl get secret tls-secret -n default -o jsonpath="{.data.tls\.crt}" | base64 -d | openssl x509 -noout -dates
```
Nếu chứng chỉ sắp hết hạn, chạy lại generate_certs.sh:
```bash
./k8s/security/scripts/generate_certs.sh
```
Theo dõi các truy vấn MySQL chậm:
Kiểm tra slow query log của MySQL mỗi tuần:
```bash
MYSQL_POD=$(kubectl get pods -n default -l app=mysql -o name | head -n 1)
kubectl exec -it $MYSQL_POD -- cat /var/log/mysql/mysql-slow.log
```

Kiểm tra trạng thái backup hàng tuần:
Xem trạng thái backup và thử khôi phục:
```bash
velero backup get
velero restore create test-restore --from-backup mysql-backup
```






