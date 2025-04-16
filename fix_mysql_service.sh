#!/bin/bash

echo "🛠️ Fixing MySQL service name issue..."

# Delete invalid service if it exists
kubectl delete service mysql_db --ignore-not-found

# Create correct service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: mysql-db  # Changed from mysql_db to mysql-db (hyphen instead of underscore)
  namespace: default
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
  type: ClusterIP
EOF

echo "✅ MySQL service created with correct name mysql-db"

# Also create a service with mysql_db name to support backward compatibility using ExternalName
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: default
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
  type: ClusterIP
EOF

echo "✅ Created additional MySQL service with name mysql" 