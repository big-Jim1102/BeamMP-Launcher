# Building BeamMP Launcher .deb Packages for Linux

This guide explains how to build `.deb` packages for the BeamMP Launcher on Linux. This is useful for distributing the launcher to Debian/Ubuntu users.

## Prerequisites

### System Requirements
- Linux (Debian/Ubuntu recommended)
- Git
- CMake (3.10 or higher)
- C++ compiler with C++20 support (GCC 10+ or Clang 12+)
- vcpkg (will be automatically set up if not present)
- dpkg-dev (for creating .deb packages)

### Install System Dependencies

```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    dpkg-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    zlib1g-dev
```

## Quick Start

The easiest way to build a .deb package is using the provided build script:

```bash
./build-deb.sh
```

This will:
1. Check for all required dependencies
2. Set up vcpkg if needed
3. Build the launcher
4. Create a .deb package

### Specify a Version

You can specify a version manually:

```bash
./build-deb.sh 2.0.0
```

If no version is specified, the script will try to get it from git tags (e.g., `v2.0.0` → `2.0.0`), or default to `1.0.0`.

## Manual Build Process

If you prefer to build manually:

### 1. Clone the Repository

```bash
git clone https://github.com/BeamMP/BeamMP-Launcher.git
cd BeamMP-Launcher
```

### 2. Set Up vcpkg

```bash
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.sh
cd ..
```

### 3. Configure and Build

```bash
mkdir build-deb
cd build-deb

cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=../vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCPACK_PACKAGE_VERSION="2.0.0"

cmake --build . --config Release -j$(nproc)
```

### 4. Create .deb Package

```bash
cpack -G DEB
```

The `.deb` file will be created in the `build-deb` directory.

## Package Information

The generated .deb package will:
- Install `BeamMP-Launcher` to `/usr/bin/beammp-launcher`
- Be named `beammp-launcher-<version>-<arch>.deb`
- Include proper metadata (description, maintainer, etc.)

### Install the Package

After building, you can install it:

```bash
sudo dpkg -i beammp-launcher-*.deb
```

If there are missing dependencies:

```bash
sudo apt-get install -f
```

### Test the Installation

```bash
beammp-launcher --help
```

## Updating for New Releases

When a new release comes out, follow these steps:

### 1. Update the Source Code

```bash
git fetch origin
git checkout master  # or the release tag
git pull
```

Or for a specific release tag:

```bash
git fetch --tags
git checkout v2.1.0  # Replace with the actual tag
```

### 2. Build the New Version

The version will be automatically detected from the git tag:

```bash
./build-deb.sh
```

Or specify it manually:

```bash
./build-deb.sh 2.1.0
```

### 3. Verify the Package

Check the package contents:

```bash
dpkg-deb -I beammp-launcher-*.deb
dpkg-deb -c beammp-launcher-*.deb
```

### 4. Test Installation

```bash
# Remove old version if installed
sudo apt-get remove beammp-launcher

# Install new version
sudo dpkg -i beammp-launcher-*.deb
sudo apt-get install -f  # Fix any dependency issues
```

### 5. Publish to GitHub

1. Create a new release on GitHub
2. Upload the `.deb` file(s) as release assets
3. Optionally create a GitHub Actions workflow to automate this (see below)

## Automation with GitHub Actions

You can automate the build process using GitHub Actions. Create `.github/workflows/build-deb.yml`:

```yaml
name: Build .deb Package

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:
    inputs:
      version:
        description: 'Version number'
        required: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y \
            build-essential \
            cmake \
            git \
            dpkg-dev \
            libssl-dev \
            libcurl4-openssl-dev \
            zlib1g-dev
      
      - name: Setup vcpkg
        run: |
          git clone https://github.com/Microsoft/vcpkg.git
          cd vcpkg
          ./bootstrap-vcpkg.sh
      
      - name: Build .deb
        run: |
          chmod +x build-deb.sh
          if [ "${{ github.event_name }}" == "workflow_dispatch" ]; then
            ./build-deb.sh "${{ github.event.inputs.version }}"
          else
            ./build-deb.sh
          fi
        env:
          VCPKG_ROOT: ${{ github.workspace }}/vcpkg
      
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: beammp-launcher-deb
          path: build-deb/*.deb
      
      - name: Create Release
        if: startsWith(github.ref, 'refs/tags/')
        uses: softprops/action-gh-release@v1
        with:
          files: build-deb/*.deb
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Troubleshooting

### vcpkg Dependencies Fail to Build

If vcpkg dependencies fail to build, try:

```bash
cd vcpkg
./vcpkg install cpp-httplib nlohmann-json zlib openssl curl --triplet x64-linux
```

### CMake Can't Find Packages

Make sure vcpkg is properly set up and the toolchain file path is correct:

```bash
export VCPKG_ROOT=$(pwd)/vcpkg
cmake .. -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake
```

### Build Fails with Linker Errors

Ensure all system dependencies are installed:

```bash
sudo apt-get install -y libssl-dev libcurl4-openssl-dev zlib1g-dev
```

### Package Installation Fails

Check for missing dependencies:

```bash
dpkg-deb -I beammp-launcher-*.deb
sudo apt-get install -f
```

## Architecture Support

The build script automatically detects your system architecture:
- `amd64` (x86_64)
- `i386` (32-bit x86)
- `arm64` (aarch64)
- `armhf` (ARM 32-bit)

To build for a different architecture, you'll need to use cross-compilation or build on that architecture.

## License

This build process is provided under the same license as BeamMP Launcher (AGPL-3.0).



