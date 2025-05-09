#!/bin/bash

# Generate SSH key without passphrase for GitHub Actions
echo "Generating new SSH key for GitHub Actions deployment..."
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_actions_deploy -N ""

# Display the public key
echo -e "\n--- Copy this PUBLIC key to your server's authorized_keys file ---"
cat ~/.ssh/github_actions_deploy.pub
echo -e "------------------------------------------------------------\n"

# Display the private key
echo -e "--- Copy this PRIVATE key to your GitHub repository secrets (SSH_PRIVATE_KEY) ---"
cat ~/.ssh/github_actions_deploy
echo -e "------------------------------------------------------------\n"

echo "Don't forget to:"
echo "1. Add the public key to your server's ~/.ssh/authorized_keys file"
echo "2. Add the private key to your GitHub repo secrets as SSH_PRIVATE_KEY"
echo "3. Configure other required secrets: DROPLET_IP, REMOTE_USER, REMOTE_PATH, etc." 