#!/bin/bash

# BG3 Honor Mode Save Restore Script
# This script copies backup saves to your active save directory

# Define paths
BACKUP_DIR="/home/mat/Documents/bg3_bk/"
SAVE_DIR="/home/mat/.local/share/Steam/userdata/147858825/1086940/remote/_SAVE_Public/Savegames/Story"

# Colors for output (makes it easier to read)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}BG3 Save Restore Script${NC}"
echo "=========================="

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}Error: Backup directory not found at $BACKUP_DIR${NC}"
    echo "Press Enter to exit..."
    read
    exit 1
fi

# Check if save directory exists
if [ ! -d "$SAVE_DIR" ]; then
    echo -e "${RED}Error: Save directory not found at $SAVE_DIR${NC}"
    echo "Press Enter to exit..."
    read
    exit 1
fi

# Main menu: Backup or Restore
echo
echo -e "${YELLOW}What do you want to do?${NC}"
echo "1) Backup current saves"
echo "2) Restore from backup"
echo -n "Enter choice (1 or 2): "
read main_choice

if [ "$main_choice" == "1" ]; then
    # --- BACKUP MODE ---
    echo
    echo -e "${YELLOW}Backing up current saves...${NC}"
    # Generate timestamped backup folder name
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    backup_folder="backup_$timestamp"
    backup_path="$BACKUP_DIR/$backup_folder"

    # If folder exists, confirm overwrite
    if [ -d "$backup_path" ]; then
        echo -e "${RED}Backup folder $backup_folder already exists!${NC}"
        echo -n "Overwrite? (yes/no): "
        read overwrite_confirm
        if [ "$overwrite_confirm" != "yes" ]; then
            echo "Backup cancelled."
            echo "Press Enter to exit..."
            read
            exit 0
        fi
        rm -rf "$backup_path"
    fi

    # Copy current saves to backup folder
    mkdir -p "$backup_path"
    cp -r "$SAVE_DIR"/* "$backup_path"/ 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Backup completed successfully!${NC}"
        echo -e "${GREEN}✓ Files copied from: $SAVE_DIR${NC}"
        echo -e "${GREEN}✓ Files copied to: $backup_path${NC}"
    else
        echo -e "${RED}✗ Error occurred during backup${NC}"
        echo "Press Enter to exit..."
        read
        exit 1
    fi

    echo
    echo -e "${YELLOW}Backup complete!${NC}"
    echo "Press Enter to exit..."
    read
    exit 0
elif [ "$main_choice" == "2" ]; then
    # --- RESTORE MODE ---
    # List available backups
    echo -e "${YELLOW}Available backups:${NC}"
    echo
    backup_count=0
    declare -a backup_array

    # Loop through backup directory and list folders
    for backup in "$BACKUP_DIR"/*; do
        if [ -d "$backup" ]; then
            backup_count=$((backup_count + 1))
            backup_name=$(basename "$backup")
            backup_array[$backup_count]="$backup_name"
            echo "$backup_count) $backup_name"
        fi
    done

    # Check if any backups were found
    if [ $backup_count -eq 0 ]; then
        echo -e "${RED}No backup folders found in $BACKUP_DIR${NC}"
        echo "Press Enter to exit..."
        read
        exit 1
    fi

    echo
    echo -e "${YELLOW}Which backup do you want to restore?${NC}"
    echo -n "Enter number (1-$backup_count): "
    read choice

    # Validate input
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$backup_count" ]; then
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        echo "Press Enter to exit..."
        read
        exit 1
    fi

    # Get selected backup
    selected_backup="${backup_array[$choice]}"
    backup_path="$BACKUP_DIR/$selected_backup"

    echo
    echo -e "${YELLOW}Selected backup: $selected_backup${NC}"
    echo -e "${YELLOW}This will replace all current saves in:${NC}"
    echo "$SAVE_DIR"
    echo
    echo -e "${RED}WARNING: This will permanently delete your current saves!${NC}"
    echo -n "Are you sure? (yes/no): "
    read confirmation

    if [ "$confirmation" != "yes" ]; then
        echo "Restore cancelled."
        echo "Press Enter to exit..."
        read
        exit 0
    fi

    # Make sure Steam/BG3 is not running
    echo
    echo -e "${YELLOW}Make sure Steam and BG3 are completely closed before proceeding.${NC}"
    echo -n "Press Enter when ready to continue..."
    read

    # Perform the restore
    echo
    echo -e "${YELLOW}Restoring backup...${NC}"

    # Remove existing saves
    if [ "$(ls -A "$SAVE_DIR" 2>/dev/null)" ]; then
        echo "Removing current saves..."
        rm -rf "$SAVE_DIR"/*
    fi

    # Copy backup to save directory
    echo "Copying backup files..."
    cp -r "$backup_path"/* "$SAVE_DIR"/

    # Check if copy was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Backup restored successfully!${NC}"
        echo -e "${GREEN}✓ Files copied from: $backup_path${NC}"
        echo -e "${GREEN}✓ Files copied to: $SAVE_DIR${NC}"
    else
        echo -e "${RED}✗ Error occurred during restore${NC}"
        echo "Press Enter to exit..."
        read
        exit 1
    fi

    echo
    echo -e "${YELLOW}Restore complete! You can now launch BG3.${NC}"
    echo "Press Enter to exit..."
    read
    exit 0
else
    echo -e "${RED}Invalid choice. Exiting.${NC}"
    echo "Press Enter to exit..."
    read
    exit 1
fi