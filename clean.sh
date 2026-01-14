#!/bin/bash

# Clean script for AtariTrader
# Removes build artifacts

set -e

echo "🧹 Cleaning AtariTrader build artifacts..."

# Remove build directory
if [ -d "build" ]; then
    echo "Removing build/ directory..."
    rm -rf build
fi

# Remove any stray 7800basic temp files in project root
echo "Removing temporary files..."
find . -name "*.asm" -type f -delete 2>/dev/null || true
find . -name "*.lst" -type f -delete 2>/dev/null || true
find . -name "*.sym" -type f -delete 2>/dev/null || true

echo "✓ Clean complete!"
echo ""
echo "Run ./build.sh to rebuild the project."
