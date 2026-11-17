#!/bin/bash
# ==========================================
# Telegram Backup Core Handler
# Author: Modified for Telegram Bot Integration
# ==========================================

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Config file location
TELEGRAM_CONFIG="/etc/telegram-backup.conf"

# Load Telegram configuration
load_telegram_config() {
    if [ ! -f "$TELEGRAM_CONFIG" ]; then
        echo -e "${RED}Error: Telegram configuration not found!${NC}"
        echo -e "${YELLOW}Please run 'autobackup' menu to setup Telegram Bot first.${NC}"
        return 1
    fi
    source "$TELEGRAM_CONFIG"
    
    if [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ]; then
        echo -e "${RED}Error: BOT_TOKEN or CHAT_ID is empty!${NC}"
        return 1
    fi
    return 0
}

# Send text message to Telegram
send_telegram_message() {
    local message="$1"
    local bot_token="$2"
    local chat_id="$3"
    
    curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
        -d chat_id="${chat_id}" \
        -d text="${message}" \
        -d parse_mode="HTML" > /dev/null 2>&1
    
    return $?
}

# Upload file to Telegram
send_telegram_file() {
    local file_path="$1"
    local caption="$2"
    local bot_token="$3"
    local chat_id="$4"
    
    if [ ! -f "$file_path" ]; then
        echo -e "${RED}Error: File not found: $file_path${NC}"
        return 1
    fi
    
    # Check file size (Telegram bot API limit is 50MB)
    local file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)
    local max_size=$((50 * 1024 * 1024)) # 50MB in bytes
    
    if [ "$file_size" -gt "$max_size" ]; then
        echo -e "${RED}Error: File size exceeds 50MB limit!${NC}"
        echo -e "${YELLOW}File size: $(($file_size / 1024 / 1024))MB${NC}"
        return 1
    fi
    
    # Upload file
    local response=$(curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendDocument" \
        -F chat_id="${chat_id}" \
        -F document=@"${file_path}" \
        -F caption="${caption}" \
        -F parse_mode="HTML")
    
    # Check if upload successful
    if echo "$response" | grep -q '"ok":true'; then
        # Extract file_id for future reference
        local file_id=$(echo "$response" | grep -o '"file_id":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "$file_id"
        return 0
    else
        echo -e "${RED}Error: Failed to upload file to Telegram${NC}"
        echo "$response" | grep -o '"description":"[^"]*"' | cut -d'"' -f4
        return 1
    fi
}

# Get list of recent backup files from Telegram
get_telegram_backup_list() {
    local bot_token="$1"
    local chat_id="$2"
    local limit="${3:-10}"
    
    # Get recent messages from chat
    local response=$(curl -s -X POST "https://api.telegram.org/bot${bot_token}/getUpdates" \
        -d chat_id="${chat_id}" \
        -d limit="${limit}")
    
    # Parse and display backup files
    echo "$response" | grep -o '"file_id":"[^"]*"' | cut -d'"' -f4
}

# Download file from Telegram
download_telegram_file() {
    local file_id="$1"
    local output_path="$2"
    local bot_token="$3"
    
    # Get file path from Telegram
    local response=$(curl -s "https://api.telegram.org/bot${bot_token}/getFile?file_id=${file_id}")
    
    if ! echo "$response" | grep -q '"ok":true'; then
        echo -e "${RED}Error: Failed to get file info from Telegram${NC}"
        return 1
    fi
    
    local file_path=$(echo "$response" | grep -o '"file_path":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$file_path" ]; then
        echo -e "${RED}Error: Could not retrieve file path${NC}"
        return 1
    fi
    
    # Download file
    echo -e "${GREEN}Downloading file from Telegram...${NC}"
    curl -s -o "$output_path" "https://api.telegram.org/file/bot${bot_token}/${file_path}"
    
    if [ -f "$output_path" ] && [ -s "$output_path" ]; then
        echo -e "${GREEN}File downloaded successfully!${NC}"
        return 0
    else
        echo -e "${RED}Error: Failed to download file${NC}"
        return 1
    fi
}

# Validate Telegram configuration
validate_telegram_config() {
    local bot_token="$1"
    local chat_id="$2"
    
    echo -e "${YELLOW}Testing Telegram Bot connection...${NC}"
    
    # Test bot token
    local bot_info=$(curl -s "https://api.telegram.org/bot${bot_token}/getMe")
    
    if ! echo "$bot_info" | grep -q '"ok":true'; then
        echo -e "${RED}Error: Invalid BOT_TOKEN!${NC}"
        return 1
    fi
    
    local bot_username=$(echo "$bot_info" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GREEN}✓ Bot connected: @${bot_username}${NC}"
    
    # Test send message
    local test_msg="🔔 <b>Telegram Backup Test</b>\n\nYour VPS backup system is ready!\nBot: @${bot_username}\nTime: $(date '+%Y-%m-%d %H:%M:%S')"
    
    if send_telegram_message "$test_msg" "$bot_token" "$chat_id"; then
        echo -e "${GREEN}✓ Message sent successfully to chat!${NC}"
        return 0
    else
        echo -e "${RED}Error: Could not send message to CHAT_ID!${NC}"
        echo -e "${YELLOW}Make sure the bot is added to the chat and has permission to send messages.${NC}"
        return 1
    fi
}

# Clean old backups (keep only last N backups)
clean_old_telegram_backups() {
    local bot_token="$1"
    local chat_id="$2"
    local keep_count="${3:-3}"
    
    echo -e "${YELLOW}Cleaning old backups (keeping last ${keep_count})...${NC}"
    
    # Get all messages with documents
    local response=$(curl -s "https://api.telegram.org/bot${bot_token}/getUpdates?limit=100")
    
    # Extract message_ids of documents containing backup keyword
    local backup_messages=$(echo "$response" | grep -B 20 '"document"' | grep -E '"message_id":|"caption"' | \
        awk '/"caption".*[Bb]ackup/{getline; print}' | grep -o '"message_id":[0-9]*' | cut -d':' -f2 | sort -rn)
    
    # Count backups
    local count=0
    for msg_id in $backup_messages; do
        count=$((count + 1))
        if [ $count -gt $keep_count ]; then
            # Delete old backup message
            curl -s -X POST "https://api.telegram.org/bot${bot_token}/deleteMessage" \
                -d chat_id="${chat_id}" \
                -d message_id="${msg_id}" > /dev/null 2>&1
            echo -e "${GREEN}✓ Deleted old backup (message_id: ${msg_id})${NC}"
        fi
    done
    
    if [ $count -le $keep_count ]; then
        echo -e "${GREEN}✓ No old backups to clean${NC}"
    fi
}

# Main function for testing
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    echo "Telegram Backup Handler Library"
    echo "This file should be sourced, not executed directly."
    echo ""
    echo "Available functions:"
    echo "  - load_telegram_config"
    echo "  - send_telegram_message"
    echo "  - send_telegram_file"
    echo "  - download_telegram_file"
    echo "  - validate_telegram_config"
    echo "  - clean_old_telegram_backups"
fi
