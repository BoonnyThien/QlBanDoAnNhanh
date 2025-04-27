# Hướng dẫn Thiết lập CI/CD cho Dự án Quản lý Bán Đồ Ăn Nhanh

## Giới thiệu
Dự án **Quản lý Bán Đồ Ăn Nhanh (QlBanDoAnNhanh)** sử dụng một pipeline CI/CD tự động để xây dựng, kiểm tra, và triển khai ứng dụng web lên Kubernetes. Pipeline này đảm bảo mã nguồn được kiểm tra chất lượng, xây dựng thành Docker image, và triển khai an toàn lên cụm Kubernetes. Các công cụ như GitHub Actions, Docker Hub, và Kubernetes được tích hợp để tự động hóa quy trình phát triển và triển khai, giúp tăng tốc độ phát triển và đảm bảo tính ổn định của hệ thống.

Pipeline CI/CD được định nghĩa trong hai file:
1. `.github/workflows/ci-cd-tests.yml`: Tập trung vào kiểm tra, quét bảo mật, và triển khai lên Amazon ECR.
2. `.github/workflows/ci-cd.yml`: Tập trung vào kiểm tra PHP, đẩy image lên Docker Hub, và triển khai lên Kubernetes.

Dự án này thể hiện năng lực xây dựng quy trình DevOps hiện đại, tích hợp kiểm tra tự động, quét bảo mật, và triển khai liên tục, phù hợp cho các ứng dụng thương mại điện tử..

## Ứng dụng thực tiễn
- **Nhà phát triển**: Tự động hóa kiểm tra mã nguồn, xây dựng image, và triển khai, giảm thiểu lỗi thủ công.
- **DevOps**: Quản lý quy trình triển khai liên tục, tích hợp bảo mật và giám sát.
- **Người dùng cuối**: Nhận được ứng dụng ổn định, được kiểm tra và triển khai liên tục, đảm bảo trải nghiệm mượt mà.

## Yêu cầu hệ thống
- GitHub repository: 'https://github.com/BoonnyThien/QlBanDoAnNhanh.git'
- Docker Hub account với thông tin xác thực (`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`).
- AWS account với Amazon ECR và thông tin xác thực (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) (cho `ci-cd-tests.yml`).
- Cụm Kubernetes (Minikube cục bộ hoặc cụm sản xuất) với cấu hình `KUBE_CONFIG`.
- PHP 8.1 với các extension: `mbstring`, `xml`, `curl`, `mysql`, `pdo`, `pdo_mysql`.
- Composer để cài đặt dependencies PHP.
- Công cụ: `kubectl`, `helm`, `trivy`, `kube-bench`, `curl`.

## Các bước thiết lập và sử dụng CI/CD

### 1. Clone repository
```bash
git clone https://github.com/BoonnyThien/QlBanDoAnNhanh.git
cd QlBanDoAnNhanh
```

### 2. Cấu hình GitHub Secrets
Truy cập repository trên GitHub: Settings > Secrets and variables > Actions.
Thêm các secret sau:
- **DOCKERHUB_USERNAME**: Tên người dùng Docker Hub.
- **DOCKERHUB_TOKEN**: Token truy cập Docker Hub.
- **AWS_ACCESS_KEY_ID**: Khóa truy cập AWS (cho ci-cd-tests.yml).
- **AWS_SECRET_ACCESS_KEY**: Khóa bí mật AWS (cho ci-cd-tests.yml).
- **KUBE_CONFIG**: Nội dung file kubeconfig để truy cập cụm Kubernetes (cho ci-cd.yml).

### 3. Đẩy mã nguồn để kích hoạt pipeline
```bash
git add .
git commit -m "Trigger CI/CD pipeline"
git push origin main
```

### 4. Theo dõi pipeline trên GitHub Actions
Truy cập tab Actions trên GitHub repository.
Xem tiến trình của các workflow:
- **CI/CD Tests**: Kiểm tra, quét bảo mật, triển khai lên Amazon ECR.
- **CI/CD Pipeline**: Kiểm tra PHP, đẩy image lên Docker Hub, triển khai lên Kubernetes.

### 5. Kiểm tra triển khai
Kiểm tra pods trên cụm Kubernetes:
```bash
kubectl get pods
```

Kiểm tra trạng thái triển khai:
```bash
kubectl rollout status deployment/app
```

## Xử lý sự cố thường gặp

### Lỗi PHPUnit tests thất bại
- Kiểm tra log trong GitHub Actions (build-and-test job).
- Chạy test cục bộ:
```bash
composer install
vendor/bin/phpunit
```
- Sửa lỗi trong mã PHP và đẩy lại mã.

### Lỗi đẩy image lên Docker Hub
- Kiểm tra log trong build-and-push-docker job.
- Đảm bảo DOCKERHUB_USERNAME và DOCKERHUB_TOKEN đúng:
```bash
docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_TOKEN
```
- Đẩy lại image:
```bash
docker build -t $DOCKERHUB_USERNAME/doannhanh:latest .
docker push $DOCKERHUB_USERNAME/doannhanh:latest
```

### Lỗi triển khai Kubernetes
- Kiểm tra log trong deploy-to-k8s job.
- Kiểm tra cấu hình Kubernetes:
```bash
kubectl apply -f k8s/ --dry-run=client
```
- Kiểm tra KUBE_CONFIG trong GitHub Secrets.
- Áp dụng lại triển khai:
```bash
kubectl apply -f k8s/
```

### Lỗi quét bảo mật (Trivy)
- Kiểm tra file scan-*.txt trong artifacts của test job.
- Cập nhật base image trong Dockerfile để giảm lỗ hổng:
```dockerfile
FROM php:8.1-apache
```
- Chạy quét cục bộ:
```bash
trivy image buithienboo/qlbandoannhanh-php-app:1.1
```

### Lỗi kube-bench
- Kiểm tra log trong test job.
- Chạy kube-bench cục bộ:
```bash
docker run --rm -v `pwd`:/host aquasec/kube-bench:latest
```
- Sửa cấu hình Kubernetes theo khuyến nghị CIS Benchmark.

### Lỗi Amazon ECR (cho ci-cd-tests.yml)
- Kiểm tra log trong Build, tag, and push image to Amazon ECR step.
- Đảm bảo AWS_ACCESS_KEY_ID và AWS_SECRET_ACCESS_KEY đúng:
```bash
aws ecr get-login-password --region us-east-1
```
- Đẩy lại image:
```bash
docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
```

## Lệnh bổ sung

### Chạy pipeline cục bộ (giả lập)
Cài đặt act để chạy GitHub Actions cục bộ:
```bash
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

Chạy pipeline:
```bash
act -j build-and-test
act -j build-and-push-docker
act -j deploy-to-k8s
```

### Kiểm tra Docker image
```bash
docker build -t doannhanh:test .
docker run --rm doannhanh:test php vendor/bin/phpunit
```

### Kiểm tra Kubernetes deployment
```bash
kubectl get deployments
kubectl describe deployment app
kubectl logs -l app=app
```

### Kiểm tra monitoring
```bash
kubectl port-forward svc/prometheus-operator-grafana 3000:80
# Truy cập http://localhost:3000 để xem Grafana
```

## Thành phần chính và cách hoạt động

### 1. Pipeline CI/CD Tests (.github/workflows/ci-cd-tests.yml)
- **Trigger**: Khi đẩy mã lên nhánh main hoặc tạo pull request.
- **Jobs**:
  - **test**:
    - Kiểm tra mã nguồn với PHPUnit.
    - Quét bảo mật image với Trivy.
    - Chạy kube-bench để kiểm tra bảo mật Kubernetes.
  - **deploy**:
    - Đăng nhập Amazon ECR.
    - Xây dựng và đẩy image lên ECR.
    - Cập nhật deployment Kubernetes với image mới.
    - Kiểm tra trạng thái triển khai và endpoint /health, /metrics.
  - **monitor**:
    - Kiểm tra sức khỏe ứng dụng (/health).
    - Kiểm tra số liệu Prometheus (/metrics).
    - Kiểm tra logs và tài nguyên pods/nodes.

### 2. Pipeline CI/CD Pipeline (.github/workflows/ci-cd.yml)
- **Trigger**: Khi đẩy mã lên nhánh main hoặc tạo pull request.
- **Jobs**:
  - **build-and-test**:
    - Cài PHP 8.1 và các extension.
    - Cài dependencies với Composer.
    - Chạy PHPUnit tests.
  - **build-and-push-docker**:
    - Cài Docker Buildx.
    - Đăng nhập Docker Hub.
    - Xây dựng và đẩy image `buithienboo/qlbandoannhanh-php-app:1.1`.
  - **deploy-to-k8s**:
    - Cài kubectl.
    - Cấu hình kubeconfig từ KUBE_CONFIG.
    - Áp dụng các file cấu hình trong thư mục `k8s/`.

### 3. Quy trình hoạt động
- **Kiểm tra mã**: PHPUnit đảm bảo mã PHP không có lỗi logic.
- **Xây dựng image**: Docker Buildx tạo image từ Dockerfile, đảm bảo tính nhất quán.
- **Quét bảo mật**: Trivy phát hiện lỗ hổng trong image, kube-bench kiểm tra cấu hình Kubernetes.
- **Triển khai**: Image được đẩy lên Docker Hub/ECR và áp dụng vào Kubernetes deployment.
- **Giám sát**: Prometheus/Grafana thu thập số liệu, curl kiểm tra sức khỏe ứng dụng.
- **Tự động hóa**: GitHub Actions điều phối toàn bộ quy trình, giảm thiểu can thiệp thủ công.

## Truy cập và sử dụng
- **Frontend**: Truy cập qua 'http://app.example.com' hoặc URL từ Cloudflare Tunnel (được cấu hình trong Kubernetes setup).
  - **Lưu ý về Cloudflare**: Do sử dụng bản thử nghiệm, URL Cloudflare Tunnel thay đổi mỗi lần khởi động lại. Để lấy URL hiện tại, hãy kiểm tra logs của Cloudflare Tunnel:
```bash
kubectl logs -l app=cloudflared
```
- **Admin**: Quản lý hệ thống qua giao diện Admin, bảo vệ bằng TLS và Auth Service.
- **Monitoring**: Truy cập Grafana/Prometheus để xem số liệu hiệu suất (yêu cầu port-forward).
- **Logs**: Xem logs pods để debug:
```bash
kubectl logs -l app=app
```