#!/bin/bash

# This script copies the built Vite assets to the WordPress theme directory
THEME_DIR="wp-content/themes/twentytwentyfive-child"
ASSETS_DIR="$THEME_DIR/assets/dist"
BUILD_DIR="dist"

# Create the assets directory if it doesn't exist
sudo mkdir -p "$ASSETS_DIR"

# Copy the built files
sudo cp -R "$BUILD_DIR"/* "$ASSETS_DIR/"

# Set the correct ownership 
sudo chown -R www-data:www-data "$THEME_DIR"

# Set the correct permissions: 
# Directories: rwxrwxr-x (owner and group can rwx, others can rx)
# Files: rw-rw-r-- (owner and group can rw, others can r)
sudo find "$THEME_DIR" -type d -exec chmod 775 {} \;
sudo find "$THEME_DIR" -type f -exec chmod 664 {} \;

# Create a flag file for development mode
# Comment this line if you want to test production mode
sudo touch "$THEME_DIR/.vite-dev-server"
sudo chown www-data:www-data "$THEME_DIR/.vite-dev-server"
sudo chmod 664 "$THEME_DIR/.vite-dev-server" # Allow group to write/delete this too

echo "Assets copied to $ASSETS_DIR"
echo "Permissions updated for group write access."
echo "Development mode enabled (.vite-dev-server flag created)"
echo "To test production mode, remove the .vite-dev-server file"
echo "Remember to commit and push the changes to trigger deployment" 