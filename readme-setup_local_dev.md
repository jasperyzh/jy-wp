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
- [x] Initialize Git repository
- [x] Create .gitignore file
- [x] Set up GitHub repository
- [x] Configure initial commit

### 4. WordPress Configuration (Additional Steps)
- [x] Update permalinks structure
- [x] Install essential plugins for development
- [x] Set up development environment constants in wp-config.php
- [x] Configure theme customizations

#### Development Constants Added to wp-config.php
The following constants have been added to the WordPress configuration to enhance the development environment:

```php
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', true);
define('SCRIPT_DEBUG', true);
define('WP_ENVIRONMENT_TYPE', 'development');
define('WP_MEMORY_LIMIT', '256M');
define('AUTOMATIC_UPDATER_DISABLED', true);
```

#### Installed Development Plugins
- Query Monitor
- Debug Bar
- Classic Editor
- WP Super Cache
- Theme Check

#### Theme Customization
We've created a child theme based on Twenty Twenty-Five for our customizations:

- Created a child theme directory: `wp-content/themes/twentytwentyfive-child`
- Created the required files:
  - `style.css` with proper theme information and parent theme style import
  - `functions.php` with parent style enqueuing and custom footer function
- Activated the child theme
- Added a simple copyright footer text function

This child theme approach allows us to make customizations without affecting the parent theme, ensuring our changes won't be lost during theme updates.

### 5. Development Workflow
- [x] Set up local development environment
- [x] Configure deployment process
- [x] Set up CI/CD pipeline
- [x] Document deployment procedures
- [x] Test deployment, update functions.php on child-theme as test
- [x] Implement Git-based deployment workflow
- [x] Configure branch protection rules
- [x] Setup review process for deployment changes

> **Note**: See [GitHub Branch Protection Guide](./guide-github-branch-protection.md), [GitHub Secrets Guide](./guide-github-secrets.md), and [WordPress Deployment Guide](./guide-wordpress_deployment_using_sh.md) for detailed setup instructions.

### 6. Development Workflow with Vite
- [x] setup vite in twentytwentyfive-child theme
- [x] enqueue scripts.js and styles.js from vite development (instant updates or hot reload for quick development)
- [x] enqueue scripts.js and styles.js from vite production thru build-dist?

#### Vite Development Workflow

We've set up Vite for modern frontend development with our WordPress child theme:

1. **Directory Structure**:
   - `/src/main.js` - Main JavaScript entry point
   - `/src/styles.scss` - Main stylesheet using SASS
   - `/dist/` - Temporary build directory (not committed to Git)
   - `/wp-content/themes/twentytwentyfive-child/assets/dist/` - Final location for built assets

2. **Development Commands**:
   ```bash
   # Start development server with hot reloading
   npm run dev
   
   # Build assets for production
   npm run build
   
   # Build assets and copy to theme directory
   npm run build-theme
   
   # Build and watch for changes
   npm run watch
   ```

3. **Switching Between Dev and Production**:
   - Development mode: Create a `.vite-dev-server` file in the theme directory
   - Production mode: Remove the `.vite-dev-server` file

4. **Permission Handling**:
   - We build to a local `/dist/` directory first
   - Then use `copy-to-theme.sh` script to copy with proper permissions

5. **Deployment Process**:
   - Built files are stored in the theme's `/assets/dist/` directory
   - These are committed to Git and deployed with the theme
   - Assets use content hashing for cache busting

### 7. Git-Based Deployment Strategy
- [x] Finalize GitHub Actions workflow for automated deployments
- [x] Implement branch strategy (main → production, develop → staging)
- [x] Setup proper SSH key management for secure deployments
  - SSH keys without passphrases are required for automated deployments
  - See the Troubleshooting section in [WordPress Deployment Guide](./guide-wordpress_deployment_using_sh.md)
  - Add public key to the server:
    ```bash
    cat ~/.ssh/github_deploy_key.pub | ssh root@your-droplet-ip "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
    ```
- [x] Configure pre-deployment testing
- [x] Implement post-deployment verification
- [x] Document rollback procedures
- [x] Successfully test deployment pipeline with child theme updates (style.css and functions.php updates)

### 8. Webhook via WordPress Dashboard
- [ ] Create a simple astro project in Vercel (1 html landing page)
- [ ] Add a Webhook test button in WordPress Dashboard to rebuild the astro project on Vercel
- [ ] Enable a webhook button to call vercel to rebuild the astro project
- [ ] Deploy/copy the simple astro project into DigitalOcean Droplet
- [ ] make sure the astro project ran and viewable through the public IP or domain
- [ ] Add a webhook button to interact with droplet server
- [ ] Add a webhook button to rebuild the astro project on the server

### 9. Add JS Frameworks to Vite for WordPress
- [ ] add simple component of Vue.js
- [ ] add simple component of React.js

#### Local Development Environment
We've successfully set up a complete local development environment with:
- Docker containers for WordPress, MySQL, and phpMyAdmin
- WP-CLI for command-line management
- Essential development plugins
- Debugging enabled in wp-config.php
- Child theme for theme customizations
- Git version control

#### Deployment Process
We've configured a reliable deployment process with three options:
1. **Manual deployment** using the `deploy.sh` script
2. **Targeted deployment** using the `deploy-child-theme.sh` script
3. **Automated deployment** using GitHub Actions

These deployment methods include:
- Automatic backups before deployment (only of files being modified)
- Targeted synchronization of only modified theme/plugin files
- Non-destructive deployment (preserves existing files not in repository)
- Protection of parent themes during deployment
- Automatic installation of required parent themes if missing
- Cache clearing after deployment

For maximum reliability and version control, we're transitioning to a fully Git-based deployment strategy using GitHub Actions, which offers these additional benefits:
- Complete version history
- Conflict detection and resolution
- Team collaboration through pull requests
- Automated testing before deployment
- Easy rollback capabilities

See `readme-deployment.md` for detailed deployment procedures.

#### Testing Your Installation
Before deploying, you can use the `test-installation.sh` script to verify that your WordPress installation is correctly set up:

```bash
./test-installation.sh
```

This script checks:
- If Docker containers are running
- If WordPress is accessible
- If the child theme is active
- If required plugins are installed and active
- If debugging is enabled

## Server Information
- Droplet: wordpress645onubuntu2204-s-1vcpu-1gb-sgp1-01
- Region: SGP1
- Resources: 1GB RAM / 25GB Disk

## Development Guidelines
- Use Docker for local environment
- Version control with Git
- Deploy via GitHub Actions CI/CD
- Use feature branches for development
- Submit changes via pull requests
- Keep custom code in functions.php initially
- Document all changes

## Next Steps
1. ✅ Complete Git-based deployment workflow
2. ✅ Configure branch protection rules
3. ✅ Setup development → staging → production pipeline
4. ✅ Document rollback procedures
5. [ ] Implement automated testing
6. [ ] Setup Vite in the child theme for development
7. [ ] Add webhook functionality to WordPress Dashboard

## Deployment Summary
We've successfully implemented and tested a complete CI/CD pipeline with:

- **GitHub Repository Structure**:
  - `main` branch: Production environment
  - `develop` branch: Staging environment
  - `feature-*` branches: Local development

- **Deployment Process**:
  - Automated deployments via GitHub Actions
  - Non-destructive file synchronization (preserves WordPress core and third-party files)
  - Target-specific deployments (only syncs modified child theme and custom plugins)
  - Automated parent theme preservation and installation
  - Pre and post-deployment verification

- **SSH Configuration**:
  - SSH keys without passphrases for automated deployment
  - Secure key management via GitHub Secrets
  - Proper file permissions for SSH directories

- **Frontend Development**:
  - Vite for modern JavaScript and CSS processing
  - Development server with hot reloading
  - Optimized production builds with content hashing
  - Automatic asset enqueuing in WordPress