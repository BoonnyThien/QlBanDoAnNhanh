#!/bin/bash

echo "🔧 Creating PHP error configuration..."

# Create error.ini file
cat > /tmp/error.ini << EOF
error_reporting=E_ALL
log_errors=On
error_log=/var/log/php_errors.log
display_errors=On
display_startup_errors=On
EOF

# Create ConfigMap
kubectl delete configmap php-error-config --ignore-not-found
kubectl create configmap php-error-config --from-file=error.ini=/tmp/error.ini

echo "✅ PHP error configuration created"

# Clean up
rm /tmp/error.ini 