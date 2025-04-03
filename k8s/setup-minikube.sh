#!/bin/bash

# Function to check if a resource exists
check_resource_exists() {
    kubectl get $1 $2 >/dev/null 2>&1
    return $?
}

# Function to wait for ingress controller to be ready
wait_for_ingress_controller() {
    echo "Waiting for ingress controller to be ready..."
    while ! kubectl get pods -n ingress-nginx | grep -q "Running"; do
        sleep 5
    done
    echo "Ingress controller is ready!"
}

# Start Minikube
echo "Starting Minikube..."
minikube start --driver=docker

# Enable ingress addon
echo "Enabling ingress addon..."
minikube addons enable ingress

# Create monitoring namespace
echo "Creating monitoring namespace..."
kubectl create namespace monitoring

# Install Prometheus Operator CRDs
echo "Installing Prometheus Operator CRDs..."
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml

# Install Prometheus Operator
echo "Installing Prometheus Operator..."
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/bundle.yaml

# Create directory for persistent volume
echo "Creating directory for persistent volume..."
minikube ssh "sudo mkdir -p /mnt/data/mysql && sudo chmod 777 /mnt/data/mysql"

# Delete existing resources if they exist
echo "Cleaning up existing resources..."
kubectl delete secret mysql-secret --ignore-not-found
kubectl delete configmap mysql-init-script --ignore-not-found
kubectl delete configmap apache-config --ignore-not-found
kubectl delete configmap php-code --ignore-not-found
kubectl delete configmap php-code-content --ignore-not-found
kubectl delete pvc mysql-pvc --ignore-not-found
kubectl delete pv mysql-pv --ignore-not-found
kubectl delete statefulset mysql --ignore-not-found
kubectl delete service mysql-service --ignore-not-found
kubectl delete ingress php-app-ingress --ignore-not-found
kubectl delete deployment php-app --ignore-not-found
kubectl delete servicemonitor php-app-monitor --ignore-not-found
kubectl delete servicemonitor mysql-monitor --ignore-not-found

# Wait for resources to be deleted
sleep 10

# Create secrets with correct password
echo "Creating MySQL secrets..."
kubectl create secret generic mysql-secret \
  --from-literal=root-password=$(echo -n "rootpass" | base64) \
  --from-literal=user-password=$(echo -n "dXNlcnBhc3M" | base64)

# Apply configurations
echo "Applying Kubernetes configurations..."
kubectl apply -f mysql-init-script.yaml
kubectl apply -f apache-config.yaml
kubectl apply -f php-code.yaml
kubectl apply -f persistent-volume.yaml
kubectl apply -f mysql-statefulset.yaml
kubectl apply -f deployment.yaml

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s

# Test MySQL connection
echo "Testing MySQL connection..."
kubectl exec -it mysql-0 -- mysql -uapp_user -pdXNlcnBhc3M -e "SELECT 1"

# Wait for ingress controller
wait_for_ingress_controller

# Apply ingress configuration
echo "Applying ingress configuration..."
kubectl apply -f ingress.yaml

# Wait for Prometheus Operator to be ready
echo "Waiting for Prometheus Operator to be ready..."
kubectl wait --for=condition=established crd/servicemonitors.monitoring.coreos.com --timeout=60s

# Apply Prometheus monitoring
echo "Applying Prometheus monitoring..."
kubectl apply -f prometheus-operator.yaml

# Wait for PHP app pods to be ready with increased timeout
echo "Waiting for PHP app pods to be ready..."
kubectl wait --for=condition=ready pod -l app=php-app --timeout=600s

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

# Add host entry
echo "Adding host entry..."
if grep -q "qlbandoannhanh.local" /etc/hosts; then
    sudo sed -i "s/.*qlbandoannhanh.local/$MINIKUBE_IP qlbandoannhanh.local/" /etc/hosts
else
    echo "$MINIKUBE_IP qlbandoannhanh.local" | sudo tee -a /etc/hosts
fi

# Check if all resources are running
echo "Checking resource status..."
kubectl get pods
kubectl get pv
kubectl get pvc
kubectl get services
kubectl get ingress
kubectl get servicemonitor -n monitoring

echo "Setup completed! You can access your application at http://qlbandoannhanh.local" 