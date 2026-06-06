#!/usr/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🚀 Installing ISCDN..."

# Check if running as root for system-wide install
if [[ $EUID -eq 0 ]]; then
    INSTALL_DIR="/usr/local/bin"
    echo -e "${YELLOW}⚠️  Installing system-wide (requires sudo)${NC}"
else
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    echo -e "${YELLOW}📁 Installing to user directory: $INSTALL_DIR${NC}"
fi

# Copy script
cp iscdn.sh "$INSTALL_DIR/iscdn"
chmod +x "$INSTALL_DIR/iscdn"

# Check if directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}⚠️  $INSTALL_DIR is not in your PATH${NC}"
    echo "Add this to your ~/.bashrc or ~/.zshrc:"
    echo -e "${GREEN}export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
fi

echo -e "${GREEN}✅ ISCDN installed successfully!${NC}"
echo -e "Usage: ${GREEN}iscdn <IP_ADDRESS>${NC}"