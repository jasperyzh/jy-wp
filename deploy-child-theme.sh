#!/bin/bash

# Child Theme Deployment Script
# This script deploys the twentytwentyfive-child theme to the DigitalOcean droplet

# Load configuration
CONFIG_FILE="deploy-config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    echo "Configuration loaded from $CONFIG_FILE"
else
    echo "Error: Configuration file $CONFIG_FILE not found."
    echo "Please copy deploy-config.sample.sh to deploy-config.sh and update the values."
    exit 1
fi

# Set timestamp for backups
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting child theme deployment process...${NC}"

# Define the child theme source and destination
CHILD_THEME_SOURCE="./wp-content/themes/twentytwentyfive-child/"
CHILD_THEME_DEST="$REMOTE_PATH/wp-content/themes/twentytwentyfive-child/"

# Sync the child theme
echo -e "${YELLOW}Syncing twentytwentyfive-child theme...${NC}"
rsync -avz --delete "$CHILD_THEME_SOURCE" "$REMOTE_SERVER:$CHILD_THEME_DEST"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Child theme synced successfully.${NC}"
else
    echo -e "${RED}Failed to sync child theme.${NC}"
    exit 1
fi

echo -e "${GREEN}Child theme deployment completed successfully!${NC}"
echo -e "${YELLOW}Child theme deployed to:${NC} $CHILD_THEME_DEST"
echo -e "${YELLOW}Note:${NC} You may need to manually set the file ownership on the remote server."
echo -e "Run this command on the server: sudo chown -R www-data:www-data $CHILD_THEME_DEST" 