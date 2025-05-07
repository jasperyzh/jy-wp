# Docker for WordPress Development Guide

## Understanding Docker Persistence

Docker containers are ephemeral by design, meaning when a container is destroyed, the data inside it is typically lost. However, Docker provides mechanisms to persist data across container restarts or rebuilds:

### 1. Docker Volumes

Our `docker-compose.yml` file uses two key persistence mechanisms:

```yaml
volumes:
  - db_data:/var/lib/mysql      # Named volume for database
  - ./wp-content:/var/www/html/wp-content  # Bind mount for WordPress content
```

- **Named volumes** (e.g., `db_data`): Persistent storage managed by Docker that exists outside containers.
- **Bind mounts** (e.g., `./wp-content:/var/www/html/wp-content`): Maps a directory on the host to a directory in the container.

### 2. What Persists After Docker Restarts

| Data Type | Persistence | Location |
|-----------|-------------|----------|
| Database data | ✅ Persists | Named volume `db_data` |
| WordPress core files | ❌ Does not persist | Inside container only |
| WordPress config | ✅ Persists | `./wp-content` bind mount |
| Plugins | ✅ Persists | `./wp-content/plugins` |
| Themes | ✅ Persists | `./wp-content/themes` |
| Uploads | ✅ Persists | `./wp-content/uploads` |

### 3. What Happens on Different Operations

| Operation | Command | Effect on Data |
|-----------|---------|----------------|
| Container restart | `docker-compose restart` | All data persists |
| Container stop/start | `docker-compose stop/start` | All data persists |
| Container down/up | `docker-compose down/up` | Named volumes & bind mounts persist; container-only data is lost |
| Container down with `-v` | `docker-compose down -v` | **All volume data is lost** (named volumes) |
| Docker service restart | `systemctl restart docker` | All data persists if containers auto-restart |

## WordPress Updates and Docker

When you manually update WordPress core through the dashboard or WP-CLI, these changes are made to files inside the container. When you recreate containers, these updates may be lost.

### Best Practices for WordPress Updates in Docker:

1. **Option 1**: Use the official WordPress image tag to specify the version
   ```yaml
   image: wordpress:6.8.1  # Specify exact version
   ```

2. **Option 2**: Create a custom Dockerfile that extends the WordPress image
   ```dockerfile
   FROM wordpress:latest
   # Add custom configurations here
   ```

3. **Option 3**: Use volume persistence for the entire WordPress directory
   ```yaml
   volumes:
     - ./wordpress:/var/www/html
   ```

## Working with WP-CLI in Docker Containers

### The `--allow-root` Flag

In Docker containers, processes typically run as the root user. WP-CLI includes a safety feature that warns against running commands as root in production environments. The `--allow-root` flag bypasses this warning.

### Options to Avoid Using `--allow-root`:

1. **Create a Custom Docker Image with a Non-Root User**:
   ```dockerfile
   FROM wordpress:latest
   
   # Create a non-root user
   RUN useradd -ms /bin/bash wpuser
   
   # Change permissions
   RUN chown -R wpuser:wpuser /var/www/html
   
   # Switch to non-root user
   USER wpuser
   ```

2. **Use a Shell Alias Inside the Container**:
   Create an alias in your container to automatically add the flag:
   ```bash
   RUN echo 'alias wp="wp --allow-root"' >> ~/.bashrc
   ```

3. **Create a Bash Script Wrapper**:
   
   Create a file named `docker-wp` on your host:
   ```bash
   #!/bin/bash
   docker-compose exec wordpress wp --allow-root "$@"
   ```
   
   Make it executable:
   ```bash
   chmod +x docker-wp
   ```
   
   Then use it like:
   ```bash
   ./docker-wp plugin list
   ```

## Creating a Backup Strategy
    
To ensure your WordPress site is protected, implement a consistent backup strategy:

1. **Database Backup**:
   ```bash
   docker-compose exec db mysqldump -u wordpress -pwordpress wordpress > backup_$(date +%Y%m%d).sql
   ```

2. **WordPress Files Backup**:
   ```bash
   tar -czvf wp_content_backup_$(date +%Y%m%d).tar.gz wp-content
   ```

3. **Automated Backup Script**:
   Create a file named `backup.sh`:
   ```bash
   #!/bin/bash
   TIMESTAMP=$(date +%Y%m%d)
   
   # Backup database
   docker-compose exec -T db mysqldump -u wordpress -pwordpress wordpress > backup_$TIMESTAMP.sql
   
   # Backup wp-content
   tar -czvf wp_content_backup_$TIMESTAMP.tar.gz wp-content
   
   echo "Backup completed: backup_$TIMESTAMP.sql and wp_content_backup_$TIMESTAMP.tar.gz"
   ```
   
   Make it executable:
   ```bash
   chmod +x backup.sh
   ```

## Docker Compose Commands Reference

| Task | Command |
|------|---------|
| Start containers | `docker-compose up -d` |
| Stop containers | `docker-compose down` |
| View logs | `docker-compose logs` |
| Restart a service | `docker-compose restart wordpress` |
| Execute command in container | `docker-compose exec wordpress bash` |
| Check container status | `docker-compose ps` |
| Rebuild containers | `docker-compose up -d --build` |
