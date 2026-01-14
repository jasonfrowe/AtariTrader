#!/bin/bash

# Build script for AtariTrader
# Automates CMake configuration and building

set -e  # Exit on error

echo "🎮 AtariTrader Build Script"
echo "=========================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for CMake
if ! command -v cmake &> /dev/null; then
    echo -e "${RED}Error: CMake not found${NC}"
    echo "Install CMake: brew install cmake (macOS) or sudo apt install cmake (Linux)"
    exit 1
fi

# Set 7800basic installation path
BASIC7800_DIR="/Users/jasonrowe/Software/7800basic"
BASIC7800_CMD="$BASIC7800_DIR/7800basic.sh"

# Export required environment variable for 7800basic
export bas7800dir="$BASIC7800_DIR"
export PATH="$BASIC7800_DIR:$PATH"

# Check for 7800basic
if [ ! -f "$BASIC7800_CMD" ]; then
    echo -e "${RED}Error: 7800basic not found at $BASIC7800_CMD${NC}"
    echo "Please verify the installation path"
    exit 1
fi

echo -e "${GREEN}Using 7800basic: $BASIC7800_CMD${NC}"

# Determine build directory
BUILD_DIR="build"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}Project root: $PROJECT_ROOT${NC}"

# Create build directory if it doesn't exist
if [ ! -d "$BUILD_DIR" ]; then
    echo "Creating build directory..."
    mkdir -p "$BUILD_DIR"
fi

cd "$BUILD_DIR"

# Configure with CMake
echo -e "\n${YELLOW}Configuring with CMake...${NC}"
cmake -DBASIC7800_DIR="$BASIC7800_DIR" .. || {
    echo -e "${RED}CMake configuration failed${NC}"
    exit 1
}

# Build
echo -e "\n${YELLOW}Building project...${NC}"
cmake --build . || {
    echo -e "${RED}Build failed${NC}"
    exit 1
}

# Success
echo -e "\n${GREEN}✓ Build successful!${NC}"
echo -e "Output files are in: ${GREEN}$BUILD_DIR/output/${NC}"
echo ""
ls -lh output/*.a78 2>/dev/null || echo "No .a78 files generated"
echo ""
echo "Run with an emulator:"
echo "  a7800 output/main.a78"
