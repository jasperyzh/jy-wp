# WordPress Deployment Guide

This document outlines the procedures for deploying WordPress changes from local development to the DigitalOcean production server.

## Deployment Methods

### Method 1: Manual Deployment Using deploy.sh Script

The `deploy.sh` script automates the deployment process, taking care of backups and    file synchronization.

#### Prerequisites:
- SSH access to the DigitalOcean droplet
- SSH key-based authentication set up
- rsync installed on your local machine

#### Configuration:
1. Copy the sample configuration file to create your own configuration:
   ```bash
   cp deploy-config.sample.sh deploy-config.sh
   ```

2. Edit `deploy-config.sh` and update the following variables:
   ```bash
   REMOTE_SERVER="user@your-droplet-ip"   # e.g., root@123.456.789.10
   REMOTE_PATH="/var/www/html"            # Path to WordPress on the server
   LOCAL_PATH="./wp-content"              # Path to local wp-content directory
   REMOTE_DB_NAME="wordpress"             # Remote database name
   REMOTE_DB_USER="wordpress"             # Remote database username
   REMOTE_DB_PASS="your_password"         # Remote database password
   ```

3. Make sure deploy-config.sh is not committed to your repository (it's already in .gitignore).

#### Usage:
```bash
./deploy.sh
```

#### What the Script Does:
1. Creates a backup of the remote database
2. Creates a backup of remote wp-content files
3. Syncs local theme files to the remote server
4. Syncs local plugin files to the remote server
5. Clears the cache on the remote server

### Method 2: Automated Deployment with GitHub Actions

We've set up a GitHub Actions workflow that automatically deploys changes when you push to the main branch.

#### Prerequisites:
- GitHub repository connected to your local project
- SSH key generated for deployment
- GitHub repository secrets configured

#### GitHub Secrets Required:
- `SSH_PRIVATE_KEY`: Your private SSH key for accessing the droplet
- `DROPLET_IP`: The IP address of your DigitalOcean droplet
- `REMOTE_USER`: The username on the droplet (usually 'root')
- `REMOTE_PATH`: The path to WordPress installation (usually '/var/www/html')
- `DB_USER`: Database username
- `DB_PASSWORD`: Database password
- `DB_NAME`: Database name

#### How to Set Up GitHub Secrets:

1. Go to your GitHub repository
2. Click on "Settings" > "Secrets and variables" > "Actions"
3. Click "New repository secret"
4. Add each of the required secrets mentioned above

#### Usage:
Simply push your changes to the main branch:
```bash
git add .
git commit -m "Your commit message"
git push origin main
```

The GitHub Actions workflow will automatically:
1. Connect to your DigitalOcean droplet
2. Create backups
3. Sync theme files
4. Sync plugin files
5. Clear the cache

## Best Practices

### 1. Always Test Changes Locally First
Make sure your changes work correctly in your local development environment before deploying.

### 2. Use Version Control
Always commit your changes to Git. This provides a history of changes and makes rollbacks easier.

### 3. Create Backups Before Deployment
The deployment script creates backups, but it's good practice to manually create backups before major changes.

### 4. Maintain Database Consistency
If you've made database changes locally that need to be reflected on the production site, export those specific changes (not the entire database) and apply them carefully.

### 5. Monitor After Deployment
After deployment, monitor the site for any issues or errors.

## Rollback Procedure

If something goes wrong during deployment, you can restore from the backups:

### 1. Restore Database:
```bash
ssh user@your-droplet-ip
mysql -u wordpress -p wordpress < ~/wordpress_backup_TIMESTAMP.sql
```

### 2. Restore Files:
```bash
ssh user@your-droplet-ip
rm -rf /var/www/html/wp-content
tar -xzf ~/wp-content_backup_TIMESTAMP.tar.gz -C /
```

## Security Considerations

- Never store sensitive credentials in your repository
- Use SSH keys instead of passwords
- Restrict permissions on the production server
- Consider using a staging environment for testing deployments before going to production 

## Troubleshooting

### SSH Key Passphrase Issues

If your deployment fails with an error like:
```
Deploy to staging
Command failed: ssh-add - Enter passphrase for (stdin):
```

This means your SSH key is protected with a passphrase that cannot be entered during automated deployment. You have two options:

#### Option 1: Generate a new SSH key without a passphrase (for CI/CD only)
```bash
# Generate a deployment-specific SSH key without passphrase
ssh-keygen -t ed25519 -f ~/.ssh/github_deploy_key -N ""

# Display the public key to add to your server's authorized_keys
cat ~/.ssh/github_deploy_key.pub

# Display the private key to add to GitHub Secrets
cat ~/.ssh/github_deploy_key
```

Add the public key to your server's `~/.ssh/authorized_keys` file, and add the private key as a GitHub Secret named `SSH_PRIVATE_KEY`.

#### Option 2: Configure ssh-agent in GitHub Actions workflow
Update your GitHub Actions workflow file to use ssh-agent with your existing key:

```yaml
- name: Set up SSH
  uses: webfactory/ssh-agent@v0.7.0
  with:
    ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
```

This approach works with passphrase-protected keys but requires additional configuration in your workflow file.

### Permission Issues with WordFence Logs

If your deployment fails with errors like:
```
tar: ***/wp-content/wflogs/config-livewaf.php: Cannot open: Permission denied
tar: ***/wp-content/wflogs/config-transient.php: Cannot open: Permission denied
...
tar: Exiting with failure status due to previous errors
```

This is because the WordFence plugin creates log files with restricted permissions. You have two options:

#### Option 1: Exclude wflogs directory from backups
Update your deployment script or GitHub Actions workflow to exclude the wflogs directory from the backup process:

```bash
# Example for tar command in a bash script
tar -czf backup_filename.tar.gz --exclude="wp-content/wflogs" /path/to/wordpress
```

For GitHub Actions, modify the backup command:
```yaml
- name: Create files backup
  run: |
    ssh ${{ secrets.REMOTE_USER }}@${{ secrets.DROPLET_IP }} "tar -czf ~/wp-content_backup_$(date +%Y%m%d%H%M%S).tar.gz --exclude='/var/www/html/wp-content/wflogs' /var/www/html/wp-content"
```

#### Option 2: Temporarily adjust permissions (less secure)
If you need to include WordFence logs in your backups:

```bash
# Before backup
ssh user@server "chmod -R 755 /var/www/html/wp-content/wflogs"

# Run backup commands...

# After backup
ssh user@server "chmod -R 750 /var/www/html/wp-content/wflogs"
```

For security reasons, Option 1 (excluding the directory) is generally preferred. 