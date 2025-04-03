# Hướng dẫn Bảo mật

## 1. Bảo mật Container

### Quét bảo mật container
```bash
# Sử dụng Trivy để quét images
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image registry.example.com/app:latest

# Sử dụng Docker Bench để kiểm tra cấu hình
docker run --rm --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /etc:/etc:ro \
    -v /usr/bin/docker-containerd:/usr/bin/docker-containerd:ro \
    -v /usr/bin/docker-runc:/usr/bin/docker-runc:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /var/lib:/var/lib:ro \
    --label docker_bench_security \
    docker/docker-bench-security
```

### Best Practices
- Sử dụng non-root user trong container
- Cập nhật base images thường xuyên
- Giới hạn quyền truy cập mạng
- Sử dụng multi-stage builds
- Không lưu trữ secrets trong images

## 2. Bảo mật Kubernetes

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### RBAC Configuration
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

### Secrets Management
```bash
# Tạo Kubernetes secret
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret

# Sử dụng trong deployment
env:
- name: DB_USERNAME
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: username
```

## 3. Bảo mật API Gateway

### Rate Limiting
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: ratelimit
spec:
  workloadSelector:
    labels:
      app: api-gateway
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: GATEWAY
      listener:
        filterChain:
          filter:
            name: "envoy.http_connection_manager"
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.rate_limit
        typed_config:
          "@type": type.googleapis.com/envoy.config.filter.http.rate_limit.v2.RateLimit
          domain: apigateway
          timeout: 0.25s
```

### JWT Authentication
```yaml
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: jwt-auth
spec:
  selector:
    matchLabels:
      app: api-gateway
  jwtRules:
  - issuer: "https://auth.example.com"
    jwksUri: "https://auth.example.com/.well-known/jwks.json"
```

## 4. Bảo mật Dữ liệu

### Encryption at Rest
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: encryption-key
type: Opaque
data:
  key: <base64-encoded-encryption-key>
```

### Data Masking
```sql
-- Ví dụ về data masking trong MySQL
CREATE VIEW masked_users AS
SELECT 
    id,
    CONCAT(LEFT(email, 3), '***', '@', SUBSTRING_INDEX(email, '@', -1)) as email,
    CONCAT('***', RIGHT(phone, 4)) as phone
FROM users;
```

## 5. Monitoring và Audit

### Security Scanning
```bash
# Quét vulnerabilities với kube-bench
docker run --rm -v `pwd`:/host aquasec/kube-bench:latest install
./kube-bench

# Quét với kube-hunter
docker run --rm -it aquasec/kube-hunter:latest --remote <cluster-ip>
```

### Logging và Monitoring
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      read_from_head true
      <parse>
        @type json
        time_format %Y-%m-%dT%H:%M:%S.%NZ
      </parse>
    </source>
``` 