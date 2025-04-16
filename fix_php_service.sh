#!/bin/bash

echo "🔄 Creating PHP service..."

# Delete old service if it exists
kubectl delete service php-service --ignore-not-found

# Create PHP service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: php-service
  namespace: default
spec:
  selector:
    app: php
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080
  type: NodePort
EOF

# Get the service URL
service_url=$(minikube service php-service --url 2>/dev/null || echo "")
if [ -n "$service_url" ]; then
  echo "✅ PHP service created and accessible at: $service_url"
else
  echo "⚠️ PHP service created but couldn't get URL. You can check it with: minikube service php-service --url"
fi

echo "✅ PHP service fixed and created" 