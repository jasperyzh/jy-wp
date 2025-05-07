# WordPress Local Development Setup for DigitalOcean

## System Requirements
- Linux/Ubuntu
- Docker & Docker Compose
- Git
- WP-CLI
- PHP 8.2

## Initial Setup Checklist

### 1. System Information
- [x] Install neofetch: `sudo apt install neofetch`
- [x] Run system check: `neofetch`
- [x] Verify Docker installation: `docker --version` (Docker version 28.1.1)
- [x] Verify Docker Compose: `docker-compose --version` (version 1.29.2)
- [x] Install PHP 8.2: `sudo apt install php8.2-cli php8.2-curl php8.2-mysql php8.2-xml php8.2-mbstring php8.2-zip php8.2-gd`
- [x] Install WP-CLI: `curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && sudo mv wp-cli.phar /usr/local/bin/wp`

### 2. Docker Environment Setup
- [x] Create project directory
- [x] Create docker-compose.yml
- [x] Start Docker containers: `docker-compose up -d`
- [x] Verify WordPress is running at http://localhost:8000
- [x] Verify phpMyAdmin is running at http://localhost:8080
- [x] Configure WordPress installation using WP-CLI or browser setup (manual installation completed)

#### WordPress Configuration
You can configure WordPress either through the browser at http://localhost:8000 or using WP-CLI:

```bash
# Run the WordPress installation
docker-compose exec wordpress wp --allow-root core install \
  --url=http://localhost:8000 \
  --title="WordPress Development Site" \
  --admin_user=admin \
  --admin_password=adminpassword \
  --admin_email=admin@example.com

# Set permalink structure
docker-compose exec wordpress wp --allow-root rewrite structure '/%postname%/'

# Install and activate a theme (optional)
docker-compose exec wordpress wp --allow-root theme install twentytwentyfour --activate

# Install and activate essential plugins (optional)
docker-compose exec wordpress wp --allow-root plugin install query-monitor --activate
docker-compose exec wordpress wp --allow-root plugin install debug-bar --activate
docker-compose exec wordpress wp --allow-root plugin install wp-rollback --activate
```

Replace the values with your preferred settings. Make sure to use a strong password for your admin user.

### 3. Version Control Setup
- [ ] Initialize Git repository
- [ ] Create .gitignore file
- [ ] Set up GitHub repository
- [ ] Configure initial commit

### 4. WordPress Configuration (Additional Steps)
- [ ] Update permalinks structure
- [ ] Install essential plugins for development
- [ ] Set up development environment constants in wp-config.php
- [ ] Configure theme customizations

### 5. Development Workflow
- [ ] Set up local development environment
- [ ] Configure deployment process
- [ ] Set up CI/CD pipeline (future)
- [ ] Document deployment procedures

## Server Information
- Droplet: wordpress645onubuntu2204-s-1vcpu-1gb-sgp1-01
- Region: SGP1
- Resources: 1GB RAM / 25GB Disk

## Development Guidelines
- Use Docker for local environment
- Version control with Git
- Deploy via CI/CD (future)
- Keep custom code in functions.php initially
- Document all changes

## Next Steps
1. Set up Docker environment
2. Configure local WordPress installation
3. Set up version control
4. Begin development work
5. Plan deployment strategy

## Using WP-CLI with Docker

To run WP-CLI commands on your WordPress Docker container, use:

```bash
docker-compose exec wordpress wp --allow-root [command]
```

For example:
```bash
# Check WordPress version
docker-compose exec wordpress wp --allow-root core version

# List plugins
docker-compose exec wordpress wp --allow-root plugin list

# Update WordPress
docker-compose exec wordpress wp --allow-root core update

# Update plugins
docker-compose exec wordpress wp --allow-root plugin update --all
```

This allows you to manage your WordPress installation from the command line without accessing the web interface.

## Troubleshooting

### SSL Connection Timeout when Updating WordPress

If you encounter the error:
```
Download failed.: cURL error 28: SSL connection timeout
```

This is typically caused by network issues in the Docker container. Try these solutions:

#### Solution 1: Adjust Docker DNS settings
1. Create or edit `/etc/docker/daemon.json`:
   ```bash
   sudo nano /etc/docker/daemon.json
   ```

2. Add Google DNS servers:
   ```json
   {
     "dns": ["8.8.8.8", "8.8.4.4"]
   }
   ```

3. Restart Docker:
   ```bash
   sudo systemctl restart docker
   ```

4. Recreate your containers:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

#### Solution 2: Configure WP-CLI to skip SSL verification (use with caution)
```bash
docker-compose exec wordpress bash -c "wp config set WP_HTTP_DISABLE_SSL_VERIFY true --raw"
```

#### Solution 3: Manually download and update WordPress
1. Download the WordPress package on your host machine:
   ```bash
   wget https://wordpress.org/latest.zip
   ```

2. Extract it:
   ```bash
   unzip latest.zip
   ```

3. Copy files to the Docker container:
   ```bash
   docker cp wordpress/. jy-wp_wordpress_1:/var/www/html/
   ```

4. Set proper ownership:
   ```bash
   docker-compose exec wordpress chown -R www-data:www-data /var/www/html/
   ```

## Implementation Notes

### WordPress Manual Installation
We manually installed WordPress using the following process to bypass SSL verification issues:

1. Downloaded the latest WordPress package:
   ```bash
   wget https://wordpress.org/latest.zip
   ```

2. Extracted the package:
   ```bash
   unzip -q latest.zip
   ```

3. Copied WordPress files to the Docker container:
   ```bash
   docker cp wordpress/. jy-wp_wordpress_1:/var/www/html/
   ```

4. Set proper ownership of files in the container:
   ```bash
   docker-compose exec wordpress chown -R www-data:www-data /var/www/html/
   ```

This method is reliable when automatic updates fail due to SSL connection issues.