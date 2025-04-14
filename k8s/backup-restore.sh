#!/bin/bash

# Get the absolute path of the project root
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BACKUP_DIR="$PROJECT_ROOT/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

backup() {
    echo "Starting backup..."
    
    # Backup MySQL data
    echo "Backing up MySQL data..."
    kubectl exec -it $(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- mysqldump -u root -p$(kubectl get secret mysql-secret -o jsonpath='{.data.password}' | base64 --decode) qlbandoannhanh > "$BACKUP_DIR/mysql_$TIMESTAMP.sql"
    
    # Backup PHP code
    echo "Backing up PHP code..."
    tar -czf "$BACKUP_DIR/php_code_$TIMESTAMP.tar.gz" -C "$PROJECT_ROOT" phpCode
    
    # Backup uploads and sessions
    echo "Backing up uploads and sessions..."
    kubectl cp $(kubectl get pods -l app=php-app -o jsonpath='{.items[0].metadata.name}'):/var/www/html/uploads "$BACKUP_DIR/uploads_$TIMESTAMP"
    kubectl cp $(kubectl get pods -l app=php-app -o jsonpath='{.items[0].metadata.name}'):/var/www/html/sessions "$BACKUP_DIR/sessions_$TIMESTAMP"
    
    echo "Backup completed! Files are stored in $BACKUP_DIR"
}

restore() {
    if [ -z "$1" ]; then
        echo "Please provide a backup timestamp to restore from"
        echo "Available backups:"
        ls -l "$BACKUP_DIR"
        exit 1
    fi
    
    TIMESTAMP=$1
    echo "Starting restore from backup $TIMESTAMP..."
    
    # Restore MySQL data
    echo "Restoring MySQL data..."
    kubectl exec -i $(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- mysql -u root -p$(kubectl get secret mysql-secret -o jsonpath='{.data.password}' | base64 --decode) qlbandoannhanh < "$BACKUP_DIR/mysql_$TIMESTAMP.sql"
    
    # Restore PHP code
    echo "Restoring PHP code..."
    tar -xzf "$BACKUP_DIR/php_code_$TIMESTAMP.tar.gz" -C "$PROJECT_ROOT"
    
    # Restore uploads and sessions
    echo "Restoring uploads and sessions..."
    kubectl cp "$BACKUP_DIR/uploads_$TIMESTAMP" $(kubectl get pods -l app=php-app -o jsonpath='{.items[0].metadata.name}'):/var/www/html/
    kubectl cp "$BACKUP_DIR/sessions_$TIMESTAMP" $(kubectl get pods -l app=php-app -o jsonpath='{.items[0].metadata.name}'):/var/www/html/
    
    echo "Restore completed!"
}

case "$1" in
    backup)
        backup
        ;;
    restore)
        restore "$2"
        ;;
    *)
        echo "Usage: $0 {backup|restore [timestamp]}"
        exit 1
        ;;
esac 