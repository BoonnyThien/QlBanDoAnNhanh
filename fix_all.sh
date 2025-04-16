#!/bin/bash

echo "🚀 Starting to fix all issues..."

# Make all scripts executable
chmod +x fix_mysql_service.sh
chmod +x fix_php_config.sh
chmod +x fix_php_error_config.sh
chmod +x fix_php_deployment.sh
chmod +x fix_php_service.sh

# Run all fix scripts in sequence
echo "🔧 Step 1: Fixing MySQL service..."
./fix_mysql_service.sh

echo "🔧 Step 2: Fixing PHP database configuration..."
./fix_php_config.sh

echo "🔧 Step 3: Fixing PHP error configuration..."
./fix_php_error_config.sh

echo "🔧 Step 4: Fixing PHP deployment..."
./fix_php_deployment.sh

echo "🔧 Step 5: Fixing PHP service..."
./fix_php_service.sh

echo "🔍 Checking all resources..."
echo "MySQL Service:"
kubectl get service mysql
echo "MySQL-DB Service:"
kubectl get service mysql-db
echo "PHP Service:"
kubectl get service php-service
echo "PHP Deployment:"
kubectl get deployment php-deployment
echo "Running Pods:"
kubectl get pods

echo "✅ All fixes have been applied!"
echo "🌐 You can access the application at: $(minikube service php-service --url 2>/dev/null || echo 'URL not available')"
echo "📝 Check logs with: kubectl logs \$(kubectl get pods -l app=php -o jsonpath='{.items[0].metadata.name}')" 