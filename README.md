# BeamMP Launcher

The official launcher for the [BeamMP](https://beammp.com/) mod for BeamNG.drive. The launcher handles downloading the mod, launching the game, and creating connections to multiplayer servers.

## Features

- 🚀 Automatic mod download and installation
- 🎮 Seamless game launching
- 🌐 Server connection management
- 🐧 Full Linux support with desktop integration

## Installation

### Linux (Debian/Ubuntu)

#### Option 1: Install from .deb Package (Recommended)

1. **Download the latest .deb package** from the [Releases](https://github.com/BeamMP/BeamMP-Launcher/releases) page

2. **Install the package:**
   ```bash
   sudo dpkg -i beammp-launcher_*.deb
   sudo apt-get install -f  # Fix any missing dependencies
   ```

3. **Launch BeamMP Launcher:**
   - From the application menu: Search for "BeamMP Launcher" in your applications
   - From terminal: Run `BeamMP-Launcher` or `beammp-launcher`

#### Option 2: Build from Source

See [BUILD.md](BUILD.md) for detailed build instructions, or [QUICKSTART.md](QUICKSTART.md) for a quick reference.

**Quick build:**
```bash
./build-deb.sh
sudo dpkg -i beammp-launcher_*.deb
```

## Quick Start

1. **Install BeamMP Launcher** (see Installation above)

2. **Launch the application:**
   - Open "BeamMP Launcher" from your applications menu or run `BeamMP-Launcher` in terminal

3. **The launcher will:**
   - Automatically download and install the BeamMP mod
   - Launch BeamNG.drive
   - Connect you to the selected server

4. **Keep the launcher window open** while playing - closing it will disconnect you from the server!

## Requirements

### Requirements
- Debian/Ubuntu or compatible Linux distribution
- BeamNG.drive installed (Steam or standalone)
- Dependencies: `libcurl4` (or `libcurl3t64`), `libssl3` (or `libssl1.1`)

## Building from Source

**Prerequisites:**
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

**Build:**
```bash
git clone https://github.com/BeamMP/BeamMP-Launcher.git
cd BeamMP-Launcher
./build-deb.sh
```

For detailed instructions, see [BUILD.md](BUILD.md).

## Usage

### Command Line Options

```bash
BeamMP-Launcher [options]
```

Available options:
- `--verbose` - Enable verbose logging
- `--no-download` - Skip mod download
- `--no-update` - Skip launcher update check
- `--no-launch` - Don't launch the game automatically
- `--user-path <path>` - Specify custom user path

### First Time Setup

1. Launch BeamMP Launcher
2. The launcher will automatically:
   - Download the latest BeamMP mod
   - Install it to your BeamNG.drive directory
   - Launch the game

3. **Important:** Keep the launcher window open while playing!

## Troubleshooting

**Launcher won't start:**
- Check that all dependencies are installed: `sudo apt-get install -f`
- Verify BeamNG.drive is installed and accessible
- Check the terminal output for error messages

**Can't find in application menu:**
- Run `update-desktop-database` to refresh the menu
- Check that the desktop file exists: `ls /usr/share/applications/beammp-launcher.desktop`

**Connection issues:**
- Ensure your firewall allows the launcher to connect
- Check that BeamNG.drive is properly installed
- Verify you're using the latest version of the launcher

### General Issues

- **Launcher closes immediately:** Check the terminal/console for error messages
- **Mod not downloading:** Check your internet connection and firewall settings
- **Game won't launch:** Verify BeamNG.drive is installed and up to date

For more help, visit:
- [BeamMP Documentation](https://docs.beammp.com/)
- [BeamMP Forum](https://forum.beammp.com/)
- [BeamMP Discord](https://discord.gg/beammp)

## Updating

### Linux

**If installed via .deb package:**
1. Download the latest .deb package from [Releases](https://github.com/BeamMP/BeamMP-Launcher/releases)
2. Remove old version: `sudo apt-get remove beammp-launcher`
3. Install new version: `sudo dpkg -i beammp-launcher_*.deb`

**Note:** This launcher does not support automatic updates. You must manually update the launcher when new versions are released.

## Development

### Building .deb Packages

This repository includes automated build scripts for creating Debian packages:

- **Quick build:** `./build-deb.sh`
- **With version:** `./build-deb.sh 2.0.0`
- **Documentation:** See [BUILD.md](BUILD.md) for detailed instructions

### Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

See [BUILD.md](BUILD.md) for development setup instructions.

## Documentation

- [Getting Started Guide](https://docs.beammp.com/game/getting-started/)
- [Build Instructions](BUILD.md)
- [Quick Start Guide](QUICKSTART.md)
- [BeamMP Documentation](https://docs.beammp.com/)

## License

BeamMP Launcher, a launcher for the BeamMP mod for BeamNG.drive  
Copyright (C) 2024 BeamMP Ltd., BeamMP team and contributors.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

## Links

- 🌐 [BeamMP Website](https://beammp.com/)
- 📖 [Documentation](https://docs.beammp.com/)
- 💬 [Forum](https://forum.beammp.com/)
- 💬 [Discord](https://discord.gg/beammp)
- 🐛 [Report Issues](https://github.com/BeamMP/BeamMP-Launcher/issues)

---

**Note:** This launcher requires manual updates. Always check the [Releases](https://github.com/BeamMP/BeamMP-Launcher/releases) page for the latest version, especially when security updates are announced.

**Windows users:** For Windows installation, please visit the [official BeamMP website](https://beammp.com/).
