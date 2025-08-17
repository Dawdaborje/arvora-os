# Arvora OS Quick Start Guide

This guide will help you get started with Arvora OS quickly, from building the ISO to running tests.

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have:

- **Arch Linux** or **Arch-based distribution** (recommended)
- **At least 10GB free disk space**
- **4GB RAM minimum** (8GB recommended)
- **Internet connection** for downloading packages

### 1. Install Dependencies

```bash
# Install required packages
sudo pacman -Syu
sudo pacman -S archiso squashfs-tools dosfstools libisoburn mtools cdrkit syslinux

# Install testing tools (optional but recommended)
sudo pacman -S bc htop iotop iperf3 jq lsof net-tools netcat openssl procps-ng strace sysstat tree unzip wget zip
```

### 2. Clone the Repository

```bash
git clone https://github.com/Dawdaborje/arvora-os.git
cd arvora-os
```

### 3. Build the ISO

#### Option A: Standard Build

```bash
# Make the build script executable
chmod +x build.sh

# Build with testing enabled
./build.sh -c -t
```

This will:

- Clean previous builds
- Build the ISO with optimized settings
- Run tests automatically
- Generate checksums
- Place the ISO in the `output/` directory

#### Option B: Build with Calamares Installer (Recommended)

```bash
# Make the build script executable
chmod +x build-with-calamares.sh

# Build with Calamares integration and testing
./build-with-calamares.sh -t
```

This will:

- Set up Calamares installer integration
- Clean previous builds
- Build the ISO with Calamares installer
- Run tests automatically
- Generate checksums
- Place the ISO in the `out/calamares/` directory

### 4. Test the ISO

#### Option A: Test in QEMU (Recommended)

```bash
# Test the standard ISO in QEMU
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -boot d -cdrom output/arvora-os-*.iso

# Or test the Calamares ISO in QEMU
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -boot d -cdrom out/calamares/arvora-os-*.iso
```

#### Option B: Test in VirtualBox

```bash
# Create a new VM
VBoxManage createvm --name "Arvora-Test" --ostype "ArchLinux_64"
VBoxManage modifyvm "Arvora-Test" --memory 4096 --cpus 4

# Add storage controller
VBoxManage storagectl "Arvora-Test" --name "IDE Controller" --add ide

# Attach the ISO
VBoxManage storageattach "Arvora-Test" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium output/arvora-os-*.iso

# Start the VM
VBoxManage startvm "Arvora-Test"
```

### 5. Run Tests on Live System

Once the ISO boots, you can run comprehensive tests:

```bash
# Run the main test suite
arvora-test

# Generate system diagnostics
arvora-diagnostics

# View test results
cat /tmp/arvora_test_report.txt

# View diagnostic report
ls /tmp/arvora_diagnostics_*.txt
```

## 🔧 Build Options

### Standard Build Options

#### Basic Build

```bash
./build.sh
```

#### Clean Build (Recommended)

```bash
./build.sh -c
```

#### Build with Testing

```bash
./build.sh -c -t
```

#### Verbose Build

```bash
./build.sh -c -t -v
```

#### Skip Dependency Check

```bash
./build.sh --skip-deps
```

### Calamares Build Options

#### Build with Calamares (Recommended)

```bash
./build-with-calamares.sh
```

#### Build with Calamares and Testing

```bash
./build-with-calamares.sh -t
```

#### Build with Custom Output Directory

```bash
./build-with-calamares.sh -o /path/to/custom/output
```

#### Show Calamares Build Help

```bash
./build-with-calamares.sh -h
```

## 📊 Understanding Test Results

### Test Report

The test report shows:

- ✅ **Passed tests** (green)
- ❌ **Failed tests** (red)
- 📊 **Success rate percentage**
- 📝 **Detailed results in `/tmp/arvora_test_report.txt`**

### Diagnostic Report

The diagnostic report includes:

- 💻 **System information**
- 🔧 **Hardware details**
- 🌐 **Network configuration**
- 📦 **Package management status**
- ⚙️ **Service status**
- 🔍 **Performance metrics**
- ⚠️ **Common issues detection**

## 🐛 Troubleshooting

### Build Issues

**Problem:** Build fails with dependency errors

```bash
# Reinstall archiso
sudo pacman -S archiso

# Clean and rebuild
./build.sh -c
```

**Problem:** Not enough disk space

```bash
# Check available space
df -h

# Clean up
sudo pacman -Sc
rm -rf work/ output/
```

### Boot Issues

**Problem:** ISO doesn't boot

```bash
# Check ISO integrity
file output/arvora-os-*.iso
md5sum -c output/*.md5

# Try different boot options
# In QEMU: Press F12 and select different boot options
```

**Problem:** No network in live environment

```bash
# Check network status
ip addr show
systemctl status systemd-networkd

# Test connectivity
ping -c 4 8.8.8.8
```

### Test Issues

**Problem:** Tests fail

```bash
# Run diagnostics first
arvora-diagnostics

# Check system logs
journalctl -f

# Verify package database
pacman -Syy
```

## 📁 File Structure

```
arvora-os/
├── build.sh                 # Main build script
├── profiledef.sh           # ISO configuration
├── packages.x86_64         # Package list
├── pacman.conf             # Package manager config
├── airootfs/               # Live system files
│   └── usr/local/bin/
│       ├── arvora-test     # Testing framework
│       └── arvora-diagnostics # Diagnostic tool
├── work/                   # Build directory
├── output/                 # Generated ISOs
├── TESTING.md              # Detailed testing guide
└── README.md               # Project overview
```

## 🎯 Common Use Cases

### Development Testing

```bash
# Quick build and test cycle
./build.sh -c -t
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -boot d -cdrom output/arvora-os-*.iso
```

### Continuous Integration

```bash
# Automated testing
./build.sh -c -t
if [[ -f output/arvora-os-*.iso ]]; then
    echo "Build successful"
    exit 0
else
    echo "Build failed"
    exit 1
fi
```

### Performance Testing

```bash
# Boot the ISO and run performance tests
arvora-test
arvora-diagnostics

# Check performance metrics
htop
iotop
free -h
```

## 📞 Getting Help

### Documentation

- **TESTING.md** - Comprehensive testing guide
- **README.md** - Project overview and structure
- **This guide** - Quick start instructions

### Tools

- **`arvora-test`** - Run comprehensive tests
- **`arvora-diagnostics`** - Generate system diagnostics
- **`./build.sh --help`** - Show build script options

### Logs and Reports

- **Test reports:** `/tmp/arvora_test_report.txt`
- **Diagnostic reports:** `/tmp/arvora_diagnostics_*.txt`
- **Build logs:** Check terminal output or `work/build.log`

## 🚀 Next Steps

1. **Explore the codebase** - Check out the different branches for various components
2. **Run tests** - Use `arvora-test` to validate functionality
3. **Generate diagnostics** - Use `arvora-diagnostics` for troubleshooting
4. **Customize** - Modify `packages.x86_64` to add/remove packages
5. **Contribute** - Fork the repository and submit pull requests

## ⚡ Quick Commands Reference

```bash
# Build ISO
./build.sh -c -t

# Test ISO in QEMU
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -boot d -cdrom output/arvora-os-*.iso

# Run tests
arvora-test

# Generate diagnostics
arvora-diagnostics

# View test results
cat /tmp/arvora_test_report.txt

# View diagnostic report
ls /tmp/arvora_diagnostics_*.txt

# Check ISO integrity
md5sum -c output/*.md5
sha256sum -c output/*.sha256
```

---

**Happy testing! 🎉**

For more information, see the full [TESTING.md](TESTING.md) documentation.
