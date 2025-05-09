# GitHub Secrets Setup for WordPress Deployment

## Required Secrets

Set up these secrets in your GitHub repository (Settings > Secrets and variables > Actions > New repository secret):

1. **SSH_PRIVATE_KEY** - The private SSH key (without passphrase) for connecting to your server
   - Generate with `./create-deploy-key.sh` script
   - Includes the entire key with newlines (including BEGIN and END lines)

2. **DROPLET_IP** - The IP address of your DigitalOcean droplet
   - Example: `165.22.50.6`

3. **REMOTE_USER** - Username for SSH access to the droplet 
   - Example: `droplet_user`

4. **REMOTE_PATH** - Path to WordPress installation on the server
   - Example: `/var/www/html`

5. **DB_USER** - WordPress database username
   - Example: `wordpress`

6. **DB_PASSWORD** - WordPress database password
   - Use a strong password

7. **DB_NAME** - WordPress database name
   - Example: `wordpress`

## Setup Steps

1. Run the `create-deploy-key.sh` script to generate a deployment key without a passphrase:
   ```bash
   ./create-deploy-key.sh
   ```

2. Add the public key to your server's authorized_keys file:
   ```bash
   ssh droplet_user@your-droplet-ip
   echo "your-public-key-content" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

3. Add each secret to your GitHub repository:
   - Go to your repository on GitHub
   - Click on "Settings" > "Secrets and variables" > "Actions"
   - Click "New repository secret"
   - Add each secret with its exact name and value

4. Test the deployment by pushing to your repository or using the manual workflow dispatch option in GitHub Actions. 