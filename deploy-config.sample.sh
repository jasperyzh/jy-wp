#!/bin/bash

# Configuration for WordPress Deployment Script
# Copy this file to deploy-config.sh and update the values
# DO NOT commit deploy-config.sh to your repository (add it to .gitignore)

# Remote Server Details
REMOTE_SERVER="user@your-droplet-ip"   # e.g., root@123.456.789.10
REMOTE_PATH="/var/www/html"            # Path to WordPress on the server

# Local Path
LOCAL_PATH="./wp-content"              # Path to local wp-content directory

# Database Details
REMOTE_DB_NAME="wordpress"             # Remote database name
REMOTE_DB_USER="wordpress"             # Remote database username
REMOTE_DB_PASS="your_password"         # Remote database password 