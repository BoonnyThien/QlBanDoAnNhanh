#!/bin/bash

# Kiểm tra Docker daemon
echo "Kiểm tra Docker daemon..."
docker info

# Quét vulnerabilities với Trivy
echo "Quét vulnerabilities với Trivy..."
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image registry.example.com/app:latest

# Kiểm tra cấu hình Docker với Docker Bench
echo "Kiểm tra cấu hình Docker..."
docker run --rm --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /etc:/etc:ro \
    -v /usr/bin/docker-containerd:/usr/bin/docker-containerd:ro \
    -v /usr/bin/docker-runc:/usr/bin/docker-runc:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /var/lib:/var/lib:ro \
    --label docker_bench_security \
    docker/docker-bench-security

# Kiểm tra Kubernetes với kube-bench
echo "Kiểm tra Kubernetes với kube-bench..."
docker run --rm -v `pwd`:/host aquasec/kube-bench:latest install
./kube-bench

# Kiểm tra mạng với kube-hunter
echo "Kiểm tra mạng với kube-hunter..."
docker run --rm -it aquasec/kube-hunter:latest --remote <cluster-ip>

# Kiểm tra RBAC
echo "Kiểm tra RBAC..."
kubectl get clusterrolebindings
kubectl get rolebindings --all-namespaces

# Kiểm tra Network Policies
echo "Kiểm tra Network Policies..."
kubectl get networkpolicies --all-namespaces

# Kiểm tra Secrets
echo "Kiểm tra Secrets..."
kubectl get secrets --all-namespaces

# Kiểm tra Pod Security Policies
echo "Kiểm tra Pod Security Policies..."
kubectl get psp

# Kiểm tra Audit Logs
echo "Kiểm tra Audit Logs..."
kubectl get events --all-namespaces

# Kiểm tra Resource Limits
echo "Kiểm tra Resource Limits..."
kubectl get pods --all-namespaces -o json | jq '.items[].spec.containers[].resources'

# Kiểm tra Image Pull Policies
echo "Kiểm tra Image Pull Policies..."
kubectl get pods --all-namespaces -o json | jq '.items[].spec.containers[].imagePullPolicy' 