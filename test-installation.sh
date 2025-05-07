#!/bin/bash

# WordPress Installation Test Script
# This script tests if the WordPress installation is working correctly

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing WordPress Installation...${NC}"

# 1. Check if Docker containers are running
echo -e "${YELLOW}Checking Docker containers...${NC}"
if [ "$(docker-compose ps -q | wc -l)" -eq 3 ]; then
    echo -e "${GREEN}✓ All Docker containers are running.${NC}"
else
    echo -e "${RED}✗ Not all Docker containers are running. Please run 'docker-compose up -d'.${NC}"
    exit 1
fi

# 2. Test WordPress connection
echo -e "${YELLOW}Testing WordPress connection...${NC}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000)
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo -e "${GREEN}✓ WordPress is accessible at http://localhost:8000.${NC}"
else
    echo -e "${RED}✗ WordPress is not accessible. HTTP Status: $HTTP_STATUS.${NC}"
    exit 1
fi

# 3. Check WordPress version
echo -e "${YELLOW}Checking WordPress version...${NC}"
WP_VERSION=$(docker-compose exec -T wordpress wp --allow-root core version 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ WordPress version: $WP_VERSION${NC}"
else
    echo -e "${RED}✗ Could not check WordPress version.${NC}"
    exit 1
fi

# 4. Check if child theme is active
echo -e "${YELLOW}Checking if child theme is active...${NC}"
ACTIVE_THEME=$(docker-compose exec -T wordpress wp --allow-root theme list --status=active --field=name 2>/dev/null)
if [ "$ACTIVE_THEME" = "twentytwentyfive-child" ]; then
    echo -e "${GREEN}✓ Child theme 'twentytwentyfive-child' is active.${NC}"
else
    echo -e "${RED}✗ Child theme is not active. Current theme: $ACTIVE_THEME.${NC}"
    exit 1
fi

# 5. Check if required plugins are installed
echo -e "${YELLOW}Checking required plugins...${NC}"
REQUIRED_PLUGINS=("query-monitor" "debug-bar" "classic-editor" "wp-super-cache" "theme-check")
for plugin in "${REQUIRED_PLUGINS[@]}"; do
    PLUGIN_STATUS=$(docker-compose exec -T wordpress wp --allow-root plugin get $plugin --field=status 2>/dev/null)
    if [ "$PLUGIN_STATUS" = "active" ]; then
        echo -e "${GREEN}✓ Plugin '$plugin' is installed and active.${NC}"
    else
        echo -e "${RED}✗ Plugin '$plugin' is not active or not installed.${NC}"
        exit 1
    fi
done

# 6. Check if debug mode is enabled in wp-config.php
echo -e "${YELLOW}Checking if debug mode is enabled...${NC}"
DEBUG_STATUS=$(docker-compose exec -T wordpress wp --allow-root config get WP_DEBUG --format=json 2>/dev/null)
if [ "$DEBUG_STATUS" = "true" ]; then
    echo -e "${GREEN}✓ WP_DEBUG is enabled.${NC}"
else
    echo -e "${RED}✗ WP_DEBUG is not enabled.${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ All tests passed! WordPress installation is ready for deployment.${NC}"
exit 0 