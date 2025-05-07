# WordPress Deployment Guide

This document outlines the deployment strategies and procedures for our WordPress project.

## Deployment Options

We've implemented three different deployment methods:

1. **Manual deployment** using the `deploy.sh` script
2. **Targeted deployment** using the `deploy-child-theme.sh` script
3. **Automated Git-based deployment** using GitHub Actions

## Git-Based Deployment Workflow

Our primary deployment strategy uses GitHub Actions for automated, version-controlled deployments:

### Branch Strategy

- **`main` branch**: Production environment
- **`develop` branch**: Staging environment
- **Feature branches**: Development only, no direct deployment

> **Note**: For details on setting up branch protection rules, see our [GitHub Branch Protection Guide](./guide-github-branch-protection.md).

### Workflow

1. **Development**: Create a feature branch from `develop`
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/your-feature-name
   ```

2. **Development Work**: Make changes, commit frequently
   ```bash
   git add .
   git commit -m "Meaningful commit message"
   ```

3. **Push Changes**: Push your feature branch to GitHub
   ```bash
   git push -u origin feature/your-feature-name
   ```

4. **Create Pull Request**: Create a PR to merge your feature into `develop`
   - The `test.yml` workflow will automatically run tests on your PR
   - Wait for reviewers to approve your changes

5. **Merge to Develop**: Once approved, merge into `develop`
   - This triggers the `deploy.yml` workflow to deploy to staging

6. **Testing on Staging**: Verify changes work correctly on staging

7. **Production Deployment**: Create a PR from `develop` to `main`
   - After approval, merge to trigger deployment to production

8. **Verification**: Verify changes are working correctly on production

## Manual Deployment

### Using deploy.sh

The `deploy.sh` script performs a full deployment of themes and plugins:

```bash
./deploy.sh
```

This will:
1. Create remote database backup
2. Create remote files backup
3. Sync all themes
4. Sync all plugins
5. Clear WordPress cache

### Using deploy-child-theme.sh

The `deploy-child-theme.sh` script focuses on deploying only the child theme:

```bash
./deploy-child-theme.sh
```

This will:
1. Sync only the twentytwentyfive-child theme
2. Preserve all other themes and plugins

## GitHub Actions Configuration

Our GitHub Actions workflows are defined in:
- `.github/workflows/deploy.yml`: Handles deployments to staging and production
- `.github/workflows/test.yml`: Tests pull requests before merging

### Required Secrets

The following secrets need to be configured in your GitHub repository:

- `SSH_PRIVATE_KEY`: SSH key for connecting to the DigitalOcean droplet
- `DROPLET_IP`: IP address of your DigitalOcean droplet
- `REMOTE_USER`: Username for SSH access to the droplet
- `REMOTE_PATH`: Path to WordPress installation on the droplet
- `DB_USER`: WordPress database username
- `DB_PASSWORD`: WordPress database password
- `DB_NAME`: WordPress database name

## Rollback Procedures

If a deployment causes issues, you can roll back using one of these methods:

### Option 1: Deploy an older version

Create a new PR that reverts the problematic changes, or manually deploy a known working version.

### Option 2: Restore from backup

Backups are automatically created before each deployment with timestamps:

```bash
# SSH into your server
ssh droplet_user@your-droplet-ip

# List available backups
ls -la ~/*backup*

# Restore database
mysql -u your-db-user -p your-db-name < ~/wordpress_backup_TIMESTAMP.sql

# Restore files
tar -xzf ~/wp-content_backup_TIMESTAMP.tar.gz -C /
```

## Troubleshooting

### Common Deployment Issues

1. **Permission Issues**: Make sure the deployment user has proper permissions on the server
   ```bash
   # Add your user to www-data group
   sudo usermod -a -G www-data your-username
   
   # Set proper group permissions
   sudo chgrp -R www-data /var/www/html/wp-content
   sudo chmod -R g+w /var/www/html/wp-content
   ```

2. **SSH Key Issues**: Verify your SSH key is properly added to GitHub and the server

3. **Backup Failures**: Make sure there's enough disk space for backups

4. **Sync Failures**: Check network connectivity and rsync installation

## Best Practices

1. **Always test on staging before deploying to production**
2. **Use meaningful commit messages**
3. **Keep deployments small and focused**
4. **Document significant changes in commit messages**
5. **Review code before approving PRs**
6. **Verify deployments immediately after completion**
7. **Maintain regular backups outside of the deployment process** 