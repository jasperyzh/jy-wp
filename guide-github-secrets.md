# GitHub Repository Secrets Guide

This document explains how to set up GitHub repository secrets to securely store sensitive information needed for your deployment workflows.

## What are GitHub Secrets?

GitHub Secrets are encrypted environment variables that you can create for a GitHub repository. They allow you to store sensitive information (like API keys, passwords, or SSH keys) securely, making them available to GitHub Actions workflows without exposing them in your code.

## Why Use GitHub Secrets?

1. **Security**: Secrets are encrypted and only exposed to selected GitHub Actions workflows
2. **Separation of Concerns**: Keeps sensitive data out of your codebase
3. **Access Control**: Only repository administrators can manage secrets
4. **CI/CD Integration**: Enables automated workflows that require authentication
5. **Audit Trails**: GitHub maintains logs of when secrets are used (but not their values)

## Required Secrets for WordPress Deployment

For our WordPress deployment workflow, we need the following secrets:

| Secret Name      | Description                                        | Example                                              |
|------------------|----------------------------------------------------|------------------------------------------------------|
| `SSH_PRIVATE_KEY`| SSH private key for connecting to the server       | `-----BEGIN OPENSSH PRIVATE KEY-----...-----END OPENSSH PRIVATE KEY-----` |
| `DROPLET_IP`     | IP address of your DigitalOcean droplet            | `165.22.50.6`                                        |
| `REMOTE_USER`    | Username for SSH access to the droplet             | `droplet_user`                                       |
| `REMOTE_PATH`    | Path to WordPress installation on the droplet      | `/var/www/html`                                      |
| `DB_USER`        | WordPress database username                        | `wordpress`                                          |
| `DB_PASSWORD`    | WordPress database password                        | `your_secure_password`                              |
| `DB_NAME`        | WordPress database name                            | `wordpress`                                          |

## Setting Up GitHub Secrets

### Step 1: Generate an SSH Key Pair (if needed)

If you already have an SSH key for your DigitalOcean droplet, skip to Step 2.

1. Open a terminal on your local machine
2. Generate a new SSH key:
   ```bash
   ssh-keygen -t ed25519 -C "github-actions-deploy"
   ```
3. When prompted, save the key to a custom location (e.g., `~/.ssh/github_actions_deploy`)
4. Optional: set a passphrase (recommended for security)
5. Two files will be created:
   - `~/.ssh/github_actions_deploy` (private key)
   - `~/.ssh/github_actions_deploy.pub` (public key)

### Step 2: Add the Public Key to Your Server

1. Copy the public key content:
   ```bash
   cat ~/.ssh/github_actions_deploy.pub
   ```
2. SSH into your DigitalOcean droplet:
   ```bash
   ssh droplet_user@${DROPLET_IP}
   ```
3. Append the key to authorized_keys:
   ```bash
   echo "<paste_public_key_here>" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

### Step 3: Access GitHub Repository Settings

1. Navigate to your GitHub repository
2. Click on "Settings" in the top nav
3. In the left sidebar, select "Secrets and variables" → "Actions"

### Step 4: Add Each Required Secret

For each secret below:
1. Click "New repository secret"
2. Enter the Name exactly as shown
3. Paste the Value
4. Click "Add secret"

- `SSH_PRIVATE_KEY`
- `DROPLET_IP`
- `REMOTE_USER`
- `REMOTE_PATH`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`

### Step 5: Verify Secrets

1. Ensure all required secrets are listed in the "Actions" secrets page
2. To update a secret, use the three-dot menu next to its name and select "Update secret"

## Using Secrets in GitHub Actions

In your workflow YAML, reference secrets as `${{ secrets.SECRET_NAME }}`. Example:

```yaml
- name: Set up SSH
  uses: webfactory/ssh-agent@v0.7.0
  with:
    ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

- name: Deploy
  env:
    REMOTE_USER: ${{ secrets.REMOTE_USER }}
    DROPLET_IP: ${{ secrets.DROPLET_IP }}
    REMOTE_PATH: ${{ secrets.REMOTE_PATH }}
    DB_USER: ${{ secrets.DB_USER }}
    DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
    DB_NAME: ${{ secrets.DB_NAME }}
  run: |
    ssh $REMOTE_USER@$DROPLET_IP "mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > ~/backup.sql"
```

## Security Best Practices

- **Rotate secrets regularly**: Update keys/passwords periodically
- **Limit access**: Grant repository admin rights only to trusted team members
- **Minimal permissions**: Use least-privilege access for SSH keys and database users
- **Never log secrets**: Avoid echoing secrets in workflow logs

## Troubleshooting

- **Permission denied (publickey)**: Ensure your public key is in `authorized_keys` and SSH_PRIVATE_KEY matches
- **Connection refused**: Verify DROPLET_IP and firewall rules
- **Database access denied**: Check DB_USER, DB_PASSWORD, DB_NAME values and permissions

## Alternatives

For advanced secret management, consider:

- HashiCorp Vault
- AWS Secrets Manager
- External CI secret stores

## Conclusion

By setting up GitHub secrets, you've secured your CI/CD pipeline and kept sensitive data out of your codebase. Maintain, rotate, and audit secrets regularly to keep your deployments safe. 