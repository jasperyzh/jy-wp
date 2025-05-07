#!/bin/bash

# WordPress Deployment Script - DRY RUN
# This script shows what would happen during deployment without actual changes

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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}DRY RUN: ${YELLOW}Showing what would happen during deployment...${NC}"
echo -e "${BLUE}DRY RUN: ${YELLOW}No changes will be made${NC}"
echo ""

echo -e "${BLUE}DRY RUN: ${YELLOW}Remote server:${NC} $REMOTE_SERVER"
echo -e "${BLUE}DRY RUN: ${YELLOW}Remote path:${NC} $REMOTE_PATH"
echo -e "${BLUE}DRY RUN: ${YELLOW}Local path:${NC} $LOCAL_PATH"
echo -e "${BLUE}DRY RUN: ${YELLOW}Remote database:${NC} $REMOTE_DB_NAME"
echo -e "${BLUE}DRY RUN: ${YELLOW}Remote database user:${NC} $REMOTE_DB_USER"
echo ""

# 1. Would create backup of remote database
echo -e "${BLUE}DRY RUN: ${YELLOW}Would create remote database backup:${NC}"
echo -e "${BLUE}DRY RUN: ${GREEN}ssh $REMOTE_SERVER \"mysqldump -u $REMOTE_DB_USER -p**** $REMOTE_DB_NAME > ~/wordpress_backup_$TIMESTAMP.sql\"${NC}"
echo ""

# 2. Would create backup of remote files
echo -e "${BLUE}DRY RUN: ${YELLOW}Would create remote files backup:${NC}"
echo -e "${BLUE}DRY RUN: ${GREEN}ssh $REMOTE_SERVER \"tar -czf ~/wp-content_backup_$TIMESTAMP.tar.gz $REMOTE_PATH/wp-content\"${NC}"
echo ""

# 3. Would sync themes
echo -e "${BLUE}DRY RUN: ${YELLOW}Would sync themes:${NC}"
echo -e "${BLUE}DRY RUN: ${GREEN}rsync -avz --delete $LOCAL_PATH/themes/ $REMOTE_SERVER:$REMOTE_PATH/wp-content/themes/${NC}"
echo ""

# 4. Would sync plugins
echo -e "${BLUE}DRY RUN: ${YELLOW}Would sync plugins:${NC}"
echo -e "${BLUE}DRY RUN: ${GREEN}rsync -avz --delete $LOCAL_PATH/plugins/ $REMOTE_SERVER:$REMOTE_PATH/wp-content/plugins/${NC}"
echo ""

# 5. Would clear cache on remote server
echo -e "${BLUE}DRY RUN: ${YELLOW}Would clear cache on remote server:${NC}"
echo -e "${BLUE}DRY RUN: ${GREEN}ssh $REMOTE_SERVER \"cd $REMOTE_PATH && wp cache flush --allow-root\"${NC}"
echo ""

echo -e "${BLUE}DRY RUN: ${YELLOW}Backup files that would be created on remote server:${NC}"
echo -e "${BLUE}DRY RUN: ${GREEN}  - Database: ~/wordpress_backup_$TIMESTAMP.sql${NC}"
echo -e "${BLUE}DRY RUN: ${GREEN}  - Files: ~/wp-content_backup_$TIMESTAMP.tar.gz${NC}"
echo ""

# Check SSH connection
echo -e "${BLUE}DRY RUN: ${YELLOW}Testing SSH connection...${NC}"
ssh -o BatchMode=yes -o ConnectTimeout=5 $REMOTE_SERVER "echo Connection successful" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${BLUE}DRY RUN: ${GREEN}✓ SSH connection to $REMOTE_SERVER is working.${NC}"
else
    echo -e "${BLUE}DRY RUN: ${RED}✗ SSH connection to $REMOTE_SERVER failed. Please check your SSH configuration.${NC}"
fi
echo ""

# Check if rsync is installed
echo -e "${BLUE}DRY RUN: ${YELLOW}Checking if rsync is installed...${NC}"
if command -v rsync >/dev/null 2>&1; then
    echo -e "${BLUE}DRY RUN: ${GREEN}✓ rsync is installed.${NC}"
else
    echo -e "${BLUE}DRY RUN: ${RED}✗ rsync is not installed. Please install it with: sudo apt install rsync${NC}"
fi
echo ""

echo -e "${BLUE}DRY RUN: ${YELLOW}To execute the actual deployment, run:${NC} ./deploy.sh" 