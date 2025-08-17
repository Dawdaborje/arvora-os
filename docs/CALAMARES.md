# Calamares Integration for Arvora OS

This document describes the Calamares installer integration for Arvora OS, a personal Linux distribution based on Arch Linux.

## Overview

Calamares is a distribution-independent installer framework that provides a graphical interface for installing Arvora OS. The integration includes:

- **Custom branding** for Arvora OS
- **Paru support** for AUR package installation
- **Qt6 compatibility** with custom patches
- **Automatic startup** on first boot
- **Comprehensive module configuration**

## Features

### 🎨 Custom Branding

- Arvora OS themed installer
- Custom slideshow during installation
- Dark theme with modern styling
- Localized strings in multiple languages

### 📦 Package Management

- **Pacman** for official repositories
- **Paru** for AUR packages
- Automatic dependency resolution
- Retry mechanism for failed installations

### 🔧 System Configuration

- **User creation** with proper groups
- **Locale and keyboard** setup
- **Network configuration** with systemd-networkd
- **Bootloader installation** (GRUB)
- **Service management** (systemd)

### 🛡️ Security

- **Polkit integration** for privilege escalation
- **Passwordless execution** for installer
- **Secure boot support** (optional)
- **Disk encryption** support

## File Structure

### Build Output

Calamares builds are placed in a separate output directory:

```
out/
└── calamares/
    ├── arvora-os-YYYY.MM.DD-x86_64.iso
    ├── arvora-os-YYYY.MM.DD-x86_64.iso.md5
    └── arvora-os-YYYY.MM.DD-x86_64.iso.sha256
```

### Calamares Integration Files

```
airootfs/
├── etc/
│   ├── calamares/
│   │   ├── settings.conf              # Main settings
│   │   ├── modules/                   # Module configurations
│   │   │   ├── welcome.conf
│   │   │   ├── packages.conf
│   │   │   ├── bootloader.conf
│   │   │   ├── users.conf
│   │   │   ├── locale.conf
│   │   │   ├── partition.conf
│   │   │   └── ...
│   │   └── branding/
│   │       └── arvora/
│   │           └── branding.desc      # Branding configuration
│   ├── polkit-1/rules.d/
│   │   └── 49-nopasswd-calamares.rules
│   └── xdg/autostart/
│       └── calamares.desktop
├── usr/
│   ├── bin/
│   │   └── calamares_polkit          # Privilege escalation script
│   └── share/calamares/
│       └── branding/arvora/
│           ├── slideshow.qml          # Installation slideshow
│           └── style.qss              # Custom styling
└── scripts/
    └── setup-calamares.sh            # Setup script
```

## Installation Modules

### Welcome Module

- System requirements check
- Welcome message and branding
- Links to documentation and support

### Packages Module

- **Pacman backend** for official packages
- **Paru support** for AUR packages
- Automatic dependency installation
- Package group management

### Partition Module

- **Automatic partitioning** with sensible defaults
- **Manual partitioning** for advanced users
- **Encryption support** with LUKS
- **Multiple filesystem support** (ext4, btrfs, xfs, etc.)

### Users Module

- **User creation** with proper groups
- **Root password** setup
- **Hostname configuration**
- **Autologin support**

### Bootloader Module

- **GRUB installation** for UEFI and BIOS
- **Custom kernel parameters**
- **Theme integration**
- **Secure boot support**

### Network Module

- **systemd-networkd** configuration
- **DHCP and static IP** support
- **DNS configuration**
- **Network interface detection**

## Configuration

### Main Settings (`settings.conf`)

```yaml
# Module instances
instances:
  - id: "welcome"
    module: "welcome"
    config: "welcome.conf"
  # ... more modules

# Branding
branding: arvora

# Prompts
prompts:
  - type: "text"
    message: "Welcome to Arvora OS"
```

### Package Configuration (`packages.conf`)

```yaml
# Backend
backend: pacman

# Paru support
paru:
  num_retries: 3
  disable_download_timeout: false
  needed_only: true

# Package groups
packages:
  - "base"
  - "base-devel"
  - "linux"
  # ... more packages
```

### Bootloader Configuration (`bootloader.conf`)

```yaml
# Bootloader type
bootloader: grub

# Installation method
installMode: efi

# Kernel parameters
kernelParams:
  - "quiet"
  - "splash"
  - "rw"
  - "root=UUID=auto"
```

## Setup Instructions

### 1. Run the Setup Script

```bash
cd /path/to/arvora-os
./scripts/setup-calamares.sh
```

### 2. Build Arvora OS with Calamares

```bash
# Build with Calamares integration (recommended)
./build-with-calamares.sh

# Build with testing enabled
./build-with-calamares.sh -t

# Build with custom output directory
./build-with-calamares.sh -o /path/to/custom/output

# Show available options
./build-with-calamares.sh -h
```

### 3. Test the ISO

```bash
# Test the Calamares ISO
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -boot d -cdrom out/calamares/arvora-os-*.iso
```

## Customization

### Branding

Edit `airootfs/etc/calamares/branding/arvora/branding.desc` to customize:

- Component name and version
- Logo and icons
- Slideshow content
- Localized strings

### Module Configuration

Each module can be customized by editing its configuration file in `airootfs/etc/calamares/modules/`:

- `welcome.conf` - Welcome page settings
- `packages.conf` - Package installation
- `bootloader.conf` - Bootloader configuration
- `users.conf` - User creation
- `partition.conf` - Disk partitioning

### Styling

Edit `airootfs/usr/share/calamares/branding/arvora/style.qss` to customize:

- Colors and themes
- Fonts and typography
- Button and widget styling
- Layout and spacing

## Troubleshooting

### Common Issues

1. **Calamares not starting**

   - Check if polkit rules are properly installed
   - Verify desktop entry permissions
   - Check system logs for errors

2. **Package installation fails**

   - Verify internet connectivity
   - Check package repository availability
   - Review package dependencies

3. **Bootloader installation fails**
   - Check UEFI/BIOS settings
   - Verify disk partitioning
   - Review kernel parameters

### Debug Mode

Run Calamares in debug mode:

```bash
calamares -d
```

### Log Files

Check these log files for errors:

- `/var/log/calamares/`
- `/var/log/pacman.log`
- `/var/log/systemd/`

## Development

### Adding New Modules

1. Create module configuration in `airootfs/etc/calamares/modules/`
2. Add module to `settings.conf` instances list
3. Update sequence if needed
4. Test with debug mode

### Custom Patches

The integration includes custom patches for:

- **Qt6 compatibility** (`flag.patch`)
- **Paru support** (`paru-support.patch`)

### Building from Source

```bash
# Clone Calamares
git clone https://github.com/calamares/calamares.git
cd calamares

# Apply patches
git apply ../arvora_os_setup/flag.patch
git apply ../arvora_os_setup/paru-support.patch

# Build
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make
```

## Contributing

1. Fork the Arvora OS repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This Calamares integration is part of Arvora OS and is licensed under the same terms as the main project.

## Support

- **GitHub Issues**: [Arvora OS Issues](https://github.com/Dawdaborje/arvora-os/issues)
- **Documentation**: [Arvora OS README](https://github.com/Dawdaborje/arvora-os/blob/main/README.md)
- **Calamares Documentation**: [Calamares Wiki](https://github.com/calamares/calamares/wiki)

---

**Note**: This is an experimental project for learning purposes. Use at your own risk.
