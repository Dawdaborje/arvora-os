# Arvora OS

**Arvora OS** is a personal project — my own flavor of Arch Linux, built entirely from scratch as a learning and exploration journey. This is **not intended for daily or production use**, but rather as a sandbox to understand and build the components that make up a modern Linux distribution and desktop environment.

---

## 🚧 Disclaimer

This project is in early experimental stages. Most components are being developed independently and may not be stable or fully functional. Use at your own risk.

---

## 🚀 Quick Start

### Prerequisites

- **Arch Linux** or **Arch-based distribution** (recommended)
- **At least 10GB free disk space**
- **4GB RAM minimum** (8GB recommended)
- **Internet connection** for downloading packages

### Building and Testing

```bash
# Install dependencies
sudo pacman -Syu
sudo pacman -S archiso squashfs-tools dosfstools libisoburn mtools cdrkit syslinux

# Clone the repository
git clone https://github.com/Dawdaborje/arvora-os.git
cd arvora-os

# Build with testing
./build.sh -c -t

# Test the ISO
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -boot d -cdrom output/arvora-os-*.iso
```

For detailed instructions, see [QUICKSTART.md](QUICKSTART.md).

---

## 🧩 Project Structure & Modules

Each major component of the OS is being developed in its own branch. Here's a breakdown:

### 🖥️ Core System

- **Desktop Environment**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/desktop-env)

- **Window Manager**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/window-manager)

- **Login Manager**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/login-manager)

- **App Launcher**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/app-launcher)

- **Settings App**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/settings-app)

- **File Manager**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/file-manager)

- **System Tray**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/system-tray)

- **Notification Manager**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/notification-manager)

- **Power Manager**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/power-manager)

---

### 🗂️ Office Suite (Custom Applications)

- **Office Suite (Core)**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/office)

- **Office Word**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/office-word)

- **Office Excel**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/office-excel)

- **Office Publisher**
  [View Source](https://github.com/Dawdaborje/arvora-os/tree/office-publisher)

---

## 🧪 Testing Framework

Arvora OS includes a comprehensive testing framework to ensure quality and reliability:

### Built-in Testing Tools

- **`arvora-test`** - Comprehensive system testing framework
- **`arvora-diagnostics`** - System diagnostics and troubleshooting
- **`./build.sh`** - Automated build script with testing options
- **`./test-runner.sh`** - CI/CD test runner

### Running Tests

```bash
# Run comprehensive tests
arvora-test

# Generate system diagnostics
arvora-diagnostics

# Build with testing
./build.sh -c -t

# Run automated test suite
./test-runner.sh
```

### Test Reports

- **Test results:** `/tmp/arvora_test_report.txt`
- **Diagnostic reports:** `/tmp/arvora_diagnostics_*.txt`
- **CI test results:** `test-results.json`

For detailed testing information, see [TESTING.md](TESTING.md).

---

## 🛠️ Build System

### Build Script Options

```bash
# Basic build
./build.sh

# Clean build (recommended)
./build.sh -c

# Build with testing
./build.sh -c -t

# Verbose build
./build.sh -c -t -v

# Skip dependency check
./build.sh --skip-deps
```

### Optimizations

- **Zstandard compression** for faster builds and smaller ISOs
- **Optimized package selection** for better performance
- **Enhanced boot configurations** for multiple architectures
- **Automated testing** and validation
- **Comprehensive diagnostics** for troubleshooting

---

## 📦 Package Management

### Core Packages

The ISO includes essential packages for:

- **System administration** (arch-install-scripts, archinstall)
- **Hardware support** (linux-firmware, microcode)
- **Network tools** (iwd, networkmanager, openssh)
- **Storage tools** (btrfs-progs, cryptsetup, lvm2)
- **Recovery tools** (clonezilla, testdisk, gparted)
- **Development tools** (git, vim, nano)
- **Testing tools** (htop, iotop, iperf3, strace)

### Custom Tools

- **`arvora-test`** - System testing framework
- **`arvora-diagnostics`** - Diagnostic tool
- **`choose-mirror`** - Mirror selection tool
- **`Installation_guide`** - Installation guide
- **`livecd-sound`** - Audio configuration

---

## 🔧 Configuration

### Key Configuration Files

- **`profiledef.sh`** - ISO configuration and metadata
- **`packages.x86_64`** - Package list for the live system
- **`pacman.conf`** - Package manager configuration
- **`airootfs/`** - Live system files and scripts

### Customization

To customize the ISO:

1. **Add packages:** Edit `packages.x86_64`
2. **Modify configuration:** Edit `profiledef.sh`
3. **Add scripts:** Place in `airootfs/usr/local/bin/`
4. **Customize boot:** Modify files in `grub/` and `syslinux/`

---

## 🎯 Goals

- Understand the building blocks of Linux desktop environments
- Explore modular architecture for OS-level projects
- Experiment with UI/UX design, windowing systems, and application theming
- Build a hobby-level alternative to mainstream Linux desktops
- Provide comprehensive testing and validation tools
- Create an optimized and reliable build system

---

## 📊 Quality Assurance

### Testing Coverage

- **System functionality** - CPU, memory, storage, network
- **Package management** - Installation, removal, updates
- **Boot process** - BIOS/UEFI compatibility
- **Hardware detection** - PCI, USB, storage devices
- **Service management** - Systemd services and dependencies
- **Performance metrics** - Resource usage and optimization

### Continuous Integration

- **Automated builds** with dependency checking
- **ISO integrity verification** with checksums
- **Boot testing** in virtual environments
- **Comprehensive reporting** with JSON output
- **Quality metrics** and performance analysis

---

## 📌 Status

Actively being built and updated with comprehensive testing framework. Contributions and forks are welcome, but this is **not supported for public or commercial use**.

---

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide
- **[TESTING.md](TESTING.md)** - Comprehensive testing documentation
- **`./build.sh --help`** - Build script options
- **`arvora-test`** - System testing tool
- **`arvora-diagnostics --help`** - Diagnostic tool options

---

## 🔗 Author

**Dawda Borje Kujabi**
[GitHub Profile](https://github.com/Dawdaborje)

---

## 📄 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.
