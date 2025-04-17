CI/CD Pipeline Documentation
📌 Tổng quan hệ thống
------------------------------------
    A[Code Push] --> B{CI-CD.yml}
    A --> C{CI-CD-TEST.yml}
    B --> D[Build & Unit Test]
    B --> E[Docker Build]
    B --> F[K8s Deploy]
    C --> G[Security Scan]
    C --> H[Integration Test]
    C --> I[Post-Deploy Verify]
------------------------------------
1. File ci-cd.yml - Pipeline chính
🔧 Cơ chế hoạt động
------------------------------------
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant Runner as CI Runner
    participant Docker as Docker Hub
    participant K8s as Kubernetes
    
    Dev->>GH: Push code to main
    GH->>Runner: Trigger workflow
    Runner->>Runner: Setup PHP 8.1 + Extensions
    Runner->>Runner: composer install
    Runner->>Runner: Run PHPUnit tests
    Runner->>Docker: Build & Push image
    Docker->>K8s: Deploy new image
    K8s-->>GH: Report status
------------------------------------
📌 Các bước thực thi:
Kích hoạt:

Tự động chạy khi:
   Push vào nhánh main
   Tạo Pull Request vào main

Build & Test:

yaml
------------------------------------
- Setup PHP 8.1 với các extensions cần thiết
- Cài đặt dependencies qua composer
- Chạy PHPUnit tests (đạt 100% mới qua)
Docker Deployment:

yaml
------------------------------------
- Build Docker image từ Dockerfile
- Push image lên Docker Hub với tag :latest
- Triển khai lên Kubernetes cluster
🔐 Bảo mật:
Sử dụng GitHub Secrets cho:

DOCKERHUB_USERNAME/DOCKERHUB_TOKEN

KUBE_CONFIG (file cấu hình kubectl)

2. File ci-cd-test.yml - Pipeline kiểm thử nâng cao
🛡️ Cơ chế bảo mật
------------------------------------
pie
    title Security Checks
    "Container Scan" : 45
    "K8s Benchmark" : 30
    "Dependency Audit" : 25
    ------------------------------------
🔍 Quy trình kiểm thử
------------------------------------
graph LR
    A[Build Test Image] --> B[Security Scan]
    B --> C[Deploy Staging]
    C --> D[Health Check]
    D --> E[Metrics Monitoring]
    E --> F[Log Inspection]
    ------------------------------------
📌 Các bước chính:
   Container Security:

      Quét image Docker với Trivy (phát hiện CVE)
      Kiểm tra hardening K8s với kube-bench

   AWS Deployment:
------------------------------------
Copy
- Build image với Git SHA làm tag
- Push lên Amazon ECR
- Rolling update deployment K8s
   ------------------------------------
   Post-Deploy Verification:
------------------------------------
curl /health          # Kiểm tra ứng dụng sống
kubectl top pods     # Giám sát tài nguyên
kubectl logs         # Kiểm tra lỗi runtime
   ------------------------------------
🚀 Cách vận hành thực tế
Khi developer push code:
------------------------------------
graph LR
    Push-->CI[ci-cd.yml chạy tests]
    CI--Thành công-->CD[Deploy production]
    CI--Thất bại-->Notify[Thông báo lỗi]
    ------------------------------------
Hàng ngày/Manual trigger:
------------------------------------
graph LR
    Trigger-->Test[ci-cd-test.yml]
    Test-->Report[Báo cáo security]
    Report-->Jira[Tạo ticket tự động nếu có lỗi]
    ------------------------------------
🛠 Troubleshooting
------------------------------------
# Kiểm tra logs workflow:
gh run view --log <run_id>

# Chạy thủ công workflow:
gh workflow run ci-cd-test.yml

# Xóa image lỗi:
kubectl delete pod <pod-name> --force
   ------------------------------------
📝 Best Practices
Luôn kiểm tra kết quả security scan trước khi merge
Monitor resource usage sau deploy
Sử dụng feature flags cho các thay đổi lớn