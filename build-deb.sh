#!/bin/bash
set -e

# Build script for creating .deb packages of BeamMP Launcher
# Usage: ./build-deb.sh [version]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get version from argument or git
VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    if command -v git &> /dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
        GIT_VERSION=$(git describe --tags --always --dirty 2>/dev/null | sed 's/^v//' || echo "1.0.0")
        # Ensure version starts with a digit (Debian requirement)
        if [[ ! "$GIT_VERSION" =~ ^[0-9] ]]; then
            # If it doesn't start with a digit, prefix with "0."
            VERSION="0.${GIT_VERSION}"
        else
            VERSION="$GIT_VERSION"
        fi
    else
        VERSION="1.0.0"
    fi
fi

# Sanitize version: replace invalid characters and ensure it starts with a digit
# Debian versions must start with a digit and can contain [A-Za-z0-9.+~-]
if [[ ! "$VERSION" =~ ^[0-9] ]]; then
    VERSION="0.${VERSION}"
fi
# Replace any remaining invalid characters with dots
VERSION=$(echo "$VERSION" | sed 's/[^A-Za-z0-9.+~-]/./g')

echo -e "${GREEN}Building BeamMP Launcher .deb package${NC}"
echo -e "${YELLOW}Version: ${VERSION}${NC}"

# Check for required tools
echo -e "${GREEN}Checking dependencies...${NC}"
MISSING_DEPS=()

command -v cmake >/dev/null 2>&1 || MISSING_DEPS+=("cmake")
command -v g++ >/dev/null 2>&1 || MISSING_DEPS+=("g++")
command -v dpkg-deb >/dev/null 2>&1 || MISSING_DEPS+=("dpkg-dev")
# Note: vcpkg will be automatically set up if the directory doesn't exist

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo -e "${RED}Missing required dependencies: ${MISSING_DEPS[*]}${NC}"
    echo -e "${YELLOW}Install them with:${NC}"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y cmake build-essential dpkg-dev"
    echo "  # For vcpkg, see: https://vcpkg.io/en/getting-started.html"
    exit 1
fi

# Check for system dependencies (warn but don't fail - vcpkg may provide them)
echo -e "${GREEN}Checking system dependencies...${NC}"
SYSTEM_DEPS=("libssl-dev" "libcurl4-openssl-dev" "zlib1g-dev")
MISSING_SYSTEM=()

for dep in "${SYSTEM_DEPS[@]}"; do
    # Check if package is installed (handles architecture suffixes)
    if ! dpkg -l 2>/dev/null | grep -qE "^ii[[:space:]]+${dep}(:amd64|:i386|:arm64|:armhf)?[[:space:]]"; then
        MISSING_SYSTEM+=("$dep")
    fi
done

if [ ${#MISSING_SYSTEM[@]} -ne 0 ]; then
    echo -e "${YELLOW}Warning: Some system dependencies may be missing: ${MISSING_SYSTEM[*]}${NC}"
    echo -e "${YELLOW}These may be provided by vcpkg, but if the build fails, install them with:${NC}"
    echo "  sudo apt-get install -y ${MISSING_SYSTEM[*]}"
    echo -e "${YELLOW}Continuing with build...${NC}"
    echo
fi

# Setup vcpkg if needed
if [ ! -d "vcpkg" ]; then
    echo -e "${GREEN}Setting up vcpkg...${NC}"
    git clone https://github.com/Microsoft/vcpkg.git
    cd vcpkg
    ./bootstrap-vcpkg.sh
    cd ..
fi

# Configure vcpkg
VCPKG_ROOT="$SCRIPT_DIR/vcpkg"
export VCPKG_ROOT

# Create build directory
BUILD_DIR="build-deb"
echo -e "${GREEN}Creating build directory...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure CMake
echo -e "${GREEN}Configuring CMake...${NC}"
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCPACK_PACKAGE_VERSION="$VERSION"

# Build
echo -e "${GREEN}Building...${NC}"
cmake --build . --config Release -j$(nproc)

# Create .deb package
echo -e "${GREEN}Creating .deb package...${NC}"
cpack -G DEB

# Find the created .deb file
DEB_FILE=$(find . -name "*.deb" -type f | head -n 1)

if [ -n "$DEB_FILE" ]; then
    DEB_NAME=$(basename "$DEB_FILE")
    echo -e "${GREEN}✓ Package created successfully: ${DEB_NAME}${NC}"
    echo -e "${GREEN}Location: $(pwd)/${DEB_NAME}${NC}"
    
    # Show package info
    echo -e "${YELLOW}Package information:${NC}"
    dpkg-deb -I "$DEB_FILE"
    
    # Copy to parent directory for convenience
    cp "$DEB_FILE" "../${DEB_NAME}"
    echo -e "${GREEN}Also copied to: ${SCRIPT_DIR}/${DEB_NAME}${NC}"
else
    echo -e "${RED}✗ Failed to create .deb package${NC}"
    exit 1
fi

echo -e "${GREEN}Build complete!${NC}"

