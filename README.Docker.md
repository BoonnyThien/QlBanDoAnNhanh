# Docker Setup Guide

## Building and Running the Application

### Development Environment

1. **Build the images**:
```bash
# Build all services
docker compose build

# Build specific service
docker compose build php
docker compose build mysql
```
2. **Start the application**:
```bash
docker compose up -d

# Start specific service
docker compose up -d php
docker compose up -d mysql
```

3. **View logs**:
```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f php
docker compose logs -f mysql
```

### Production Environment

1. **Build for production**:
```bash
# Build with production optimizations
docker build -t myapp:prod -f Dockerfile.prod .

# Build for specific platform
docker build --platform=linux/amd64 -t myapp:prod -f Dockerfile.prod .
```

2. **Push to registry**:
```bash
# Tag image
docker tag myapp:prod myregistry.com/myapp:prod

# Push image
docker push myregistry.com/myapp:prod
```

## Development Tips

### Hot Reload
The development environment is configured with volume mounts for hot reloading:
- PHP files are mounted from `./src` to `/var/www/html`
- MySQL data is persisted in a named volume

### Database Management
```bash
# Connect to MySQL container
docker compose exec mysql mysql -uroot -p

# Import database
docker compose exec -T mysql mysql -uroot -p database_name < dump.sql

# Export database
docker compose exec mysql mysqldump -uroot -p database_name > dump.sql
```

### Container Management
```bash
# List running containers
docker compose ps

# Stop all containers
docker compose down

# Remove volumes
docker compose down -v

# Rebuild and restart specific service
docker compose up -d --build php
```

## Troubleshooting

### Common Issues

1. **Permission Issues**
```bash
# Fix permissions on mounted volumes
sudo chown -R $USER:$USER .
```

2. **Network Issues**
```bash
# Check network
docker network ls
docker network inspect doannhanh_default
```

3. **Container Issues**
```bash
# Check container logs
docker compose logs php
docker compose logs mysql

# Enter container shell
docker compose exec php bash
docker compose exec mysql bash
```

## Security Best Practices

1. Use non-root user in containers
2. Implement proper logging
3. Regular security updates
4. Proper secret management
5. Network isolation

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Security](https://docs.docker.com/engine/security/)