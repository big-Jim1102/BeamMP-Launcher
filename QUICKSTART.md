# Quick Start: Building .deb Packages

## First Time Setup

1. **Install dependencies:**
   ```bash
   sudo apt-get update
   sudo apt-get install -y build-essential cmake git dpkg-dev libssl-dev libcurl4-openssl-dev zlib1g-dev
   ```

2. **Build the package:**
   ```bash
   ./build-deb.sh
   ```

3. **Install the package:**
   ```bash
   sudo dpkg -i beammp-launcher-*.deb
   sudo apt-get install -f  # Fix any missing dependencies
   ```

## Updating for New Releases

1. **Pull the latest code:**
   ```bash
   git pull
   # OR for a specific release:
   git fetch --tags
   git checkout v2.1.0  # Replace with actual version
   ```

2. **Rebuild:**
   ```bash
   ./build-deb.sh
   ```

3. **The version is automatically detected from git tags!**

## Publishing to GitHub

1. **Create a release:**
   - Go to GitHub → Releases → Draft a new release
   - Tag: `v2.0.0` (or your version)
   - Upload the `.deb` file

2. **Or use GitHub Actions:**
   - Push a tag: `git tag v2.0.0 && git push origin v2.0.0`
   - GitHub Actions will automatically build and create a release

## Troubleshooting

- **Build fails?** Run `./build-deb.sh` and check the error messages
- **Missing dependencies?** The script will tell you what to install
- **Package won't install?** Run `sudo apt-get install -f`

For detailed information, see [BUILD.md](BUILD.md).



