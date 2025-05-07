#!/bin/bash

# WordPress Deployment Script
# This script deploys local WordPress changes to a DigitalOcean droplet

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

echo -e "${YELLOW}Starting deployment process...${NC}"

# 1. Create backup of remote database
echo -e "${YELLOW}Creating remote database backup...${NC}"
ssh $REMOTE_SERVER "mysqldump -u $REMOTE_DB_USER -p$REMOTE_DB_PASS $REMOTE_DB_NAME > ~/wordpress_backup_$TIMESTAMP.sql"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Remote database backup created successfully.${NC}"
else
    echo -e "${RED}Failed to create remote database backup. Aborting deployment.${NC}"
    exit 1
fi

# 2. Create backup of remote files
echo -e "${YELLOW}Creating remote files backup...${NC}"
ssh $REMOTE_SERVER "tar -czf ~/wp-content_backup_$TIMESTAMP.tar.gz $REMOTE_PATH/wp-content"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Remote files backup created successfully.${NC}"
else
    echo -e "${RED}Failed to create remote files backup. Aborting deployment.${NC}"
    exit 1
fi

# 3. Sync themes
echo -e "${YELLOW}Syncing themes...${NC}"
rsync -avz --delete $LOCAL_PATH/themes/ $REMOTE_SERVER:$REMOTE_PATH/wp-content/themes/

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Themes synced successfully.${NC}"
else
    echo -e "${RED}Failed to sync themes.${NC}"
    exit 1
fi

# 4. Sync plugins
echo -e "${YELLOW}Syncing plugins...${NC}"
rsync -avz --delete $LOCAL_PATH/plugins/ $REMOTE_SERVER:$REMOTE_PATH/wp-content/plugins/

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Plugins synced successfully.${NC}"
else
    echo -e "${RED}Failed to sync plugins.${NC}"
    exit 1
fi

# 5. Clear cache on remote server
echo -e "${YELLOW}Clearing cache on remote server...${NC}"
ssh $REMOTE_SERVER "cd $REMOTE_PATH && wp cache flush --allow-root"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Cache cleared successfully.${NC}"
else
    echo -e "${YELLOW}Warning: Failed to clear cache. You may need to clear it manually.${NC}"
fi

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${YELLOW}Backups created on remote server:${NC}"
echo -e "  - Database: ~/wordpress_backup_$TIMESTAMP.sql"
echo -e "  - Files: ~/wp-content_backup_$TIMESTAMP.tar.gz" 