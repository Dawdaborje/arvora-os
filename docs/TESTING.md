# Arvora OS Testing Documentation

This document provides comprehensive information about testing Arvora OS, including built-in testing tools, manual testing procedures, and troubleshooting guides.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Built-in Testing Tools](#built-in-testing-tools)
3. [Manual Testing Procedures](#manual-testing-procedures)
4. [ISO Testing](#iso-testing)
5. [Performance Testing](#performance-testing)
6. [Network Testing](#network-testing)
7. [Hardware Compatibility Testing](#hardware-compatibility-testing)
8. [Troubleshooting](#troubleshooting)
9. [Test Reports](#test-reports)
10. [Continuous Integration](#continuous-integration)

## Quick Start

### Prerequisites

Before running tests, ensure you have the following:

```bash
# Install required packages
sudo pacman -S archiso squashfs-tools dosfstools libisoburn mtools cdrkit syslinux

# Install testing tools
sudo pacman -S bc htop iotop iperf3 jq lsof net-tools netcat openssl procps-ng strace sysstat tree unzip wget zip
```

### Building and Testing

```bash
# Build the ISO with testing
./build.sh -c -t

# Run tests on a running system
arvora-test

# Generate diagnostics
arvora-diagnostics
```

## Built-in Testing Tools

### 1. Arvora Test Framework (`arvora-test`)

The main testing framework that performs comprehensive system validation.

**Usage:**

```bash
arvora-test
```

**What it tests:**

- CPU detection and performance
- Memory allocation and capacity
- Storage I/O performance
- Network connectivity and DNS
- Package management (pacman)
- Boot configuration
- System services
- Hardware detection

**Output:**

- Real-time test results with color-coded output
- Detailed report saved to `/tmp/arvora_test_report.txt`
- Success/failure summary with statistics

**Example output:**

```
=== Arvora OS Testing Framework ===
Starting comprehensive system tests...

[2024-01-15 10:30:00] Gathering system information...
✓ CPU Detection: Found 8 cores - Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz
✓ CPU Performance: Basic CPU test completed in 2.34s
✓ Memory Detection: Total RAM: 32GB
✓ Memory Allocation: Successfully allocated test memory
✓ Storage Space: Available: 500GB
✓ Disk I/O: Write test completed in 1.23s
✓ Network Interfaces: Found 3 active interfaces
✓ DNS Resolution: Successfully resolved archlinux.org
✓ Internet Connectivity: Successfully pinged 8.8.8.8
✓ Pacman: Pacman is available
✓ Package Database: Successfully synced package database
✓ Live Media: Running from Arvora OS live media
✓ Bootloader: Bootloader configuration found
✓ Systemd: System status: running
✓ Service: systemd-networkd: Service is active
✓ Service: systemd-resolved: Service is active
✓ Service: sshd: Service is active
✓ PCI Devices: Found 45 PCI devices
✓ USB Devices: Found 12 USB devices

=== Test Summary ===
Total Tests: 18
Passed: 18
Failed: 0
Success Rate: 100%
All tests passed!
```

### 2. Arvora Diagnostics (`arvora-diagnostics`)

Comprehensive system diagnostics and troubleshooting tool.

**Usage:**

```bash
arvora-diagnostics
arvora-diagnostics --help
arvora-diagnostics --version
```

**What it gathers:**

- System information (kernel, architecture, uptime)
- Hardware details (CPU, memory, storage)
- Network configuration and connectivity
- Package management status
- Service status and logs
- Process information
- Security information
- Performance metrics

**Output:**

- Comprehensive report saved to `/tmp/arvora_diagnostics_YYYYMMDD_HHMMSS.txt`
- Common issues detection
- Performance warnings

**Example sections:**

```
=== System Information ===
Date: 2024-01-15 10:30:00
Kernel: 6.1.0-arch1-1
Architecture: x86_64
Hostname: arvora-live
Uptime: 0:15:23 up 15 min, 1 user, load average: 0.52, 0.48, 0.45

=== Hardware Information ===
CPU Information:
CPU Model: Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz
CPU Cores: 8
CPU Threads: 16

Memory Information:
Total Memory: 33554432 KB
Available Memory: 31457280 KB
Free Memory: 31457280 KB

=== Common Issues Check ===
Disk usage: 15% (OK)
Memory usage: 6% (OK)
Failed services: 0 (OK)
```

## Manual Testing Procedures

### 1. Boot Testing

**Test the ISO boot process:**

```bash
# Test in QEMU
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -boot d -cdrom output/arvora-os-*.iso

# Test in VirtualBox
VBoxManage createvm --name "Arvora-Test" --ostype "ArchLinux_64"
VBoxManage modifyvm "Arvora-Test" --memory 4096 --cpus 4
VBoxManage storagectl "Arvora-Test" --name "IDE Controller" --add ide
VBoxManage storageattach "Arvora-Test" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium output/arvora-os-*.iso
VBoxManage startvm "Arvora-Test"
```

**What to verify:**

- ISO boots without errors
- All boot options work (BIOS/UEFI)
- Live environment loads correctly
- Network connectivity works
- Package management functions

### 2. Installation Testing

**Test the installation process:**

```bash
# Run archinstall in automated mode
archinstall --config /path/to/test-config.json

# Test manual installation
archinstall
```

**What to verify:**

- Installation completes successfully
- System boots after installation
- All installed packages work
- User accounts are created correctly
- Bootloader is configured properly

### 3. Package Testing

**Test package management:**

```bash
# Test package installation
sudo pacman -S htop

# Test package removal
sudo pacman -R htop

# Test package search
pacman -Ss htop

# Test package information
pacman -Qi htop

# Test package files
pacman -Ql htop
```

**What to verify:**

- Package installation works
- Package removal works
- Package search works
- Package information is correct
- Package files are installed correctly

## ISO Testing

### 1. ISO Integrity Testing

**Test ISO file integrity:**

```bash
# Verify checksums
cd output
md5sum -c *.md5
sha256sum -c *.sha256

# Test ISO structure
isoinfo -d -i arvora-os-*.iso

# Test ISO extraction
mkdir test-iso
sudo mount -o loop arvora-os-*.iso test-iso
ls -la test-iso
sudo umount test-iso
rmdir test-iso
```

### 2. ISO Boot Testing

**Test ISO boot in different environments:**

```bash
# Test in QEMU with different configurations
qemu-system-x86_64 -enable-kvm -m 2G -smp 2 -boot d -cdrom output/arvora-os-*.iso
qemu-system-x86_64 -enable-kvm -m 8G -smp 8 -boot d -cdrom output/arvora-os-*.iso

# Test with different boot modes
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -boot d -cdrom output/arvora-os-*.iso -bios /usr/share/ovmf/x64/OVMF.fd
```

## Performance Testing

### 1. System Performance

**Test system performance:**

```bash
# CPU performance
sysbench cpu --cpu-max-prime=20000 run

# Memory performance
sysbench memory --memory-block-size=1K --memory-total-size=100G run

# Disk I/O performance
sysbench fileio --file-test-mode=seqwr run

# Network performance
iperf3 -c speedtest.archlinux.org
```

### 2. Boot Performance

**Test boot performance:**

```bash
# Measure boot time
systemd-analyze time

# Analyze boot process
systemd-analyze blame

# Generate boot chart
systemd-analyze plot > boot-chart.svg
```

### 3. Memory Usage

**Test memory usage:**

```bash
# Monitor memory usage
free -h
vmstat 1 10

# Test memory allocation
stress-ng --vm 4 --vm-bytes 80% --timeout 60s
```

## Network Testing

### 1. Connectivity Testing

**Test network connectivity:**

```bash
# Test basic connectivity
ping -c 4 8.8.8.8
ping -c 4 archlinux.org

# Test DNS resolution
nslookup archlinux.org
dig archlinux.org

# Test HTTP connectivity
curl -I https://archlinux.org
wget --spider https://archlinux.org
```

### 2. Network Performance

**Test network performance:**

```bash
# Test download speed
curl -o /dev/null https://mirrors.archlinux.org/core/os/x86_64/core.db

# Test upload speed
iperf3 -c speedtest.archlinux.org -t 10

# Test latency
ping -c 10 8.8.8.8
```

### 3. Network Configuration

**Test network configuration:**

```bash
# Check network interfaces
ip addr show
ip link show

# Check routing
ip route show

# Check DNS
cat /etc/resolv.conf
systemd-resolve --status
```

## Hardware Compatibility Testing

### 1. CPU Testing

**Test CPU compatibility:**

```bash
# Check CPU features
cat /proc/cpuinfo
lscpu

# Test CPU performance
stress-ng --cpu 4 --timeout 60s

# Test CPU temperature (if available)
sensors
```

### 2. Memory Testing

**Test memory compatibility:**

```bash
# Check memory
free -h
dmidecode -t memory

# Test memory with memtest86+
# Boot from memtest86+ option in boot menu
```

### 3. Storage Testing

**Test storage compatibility:**

```bash
# Check storage devices
lsblk
fdisk -l

# Test storage performance
dd if=/dev/zero of=/tmp/test bs=1M count=1000
hdparm -t /dev/sda
```

### 4. Graphics Testing

**Test graphics compatibility:**

```bash
# Check graphics
lspci | grep -i vga
glxinfo | grep "OpenGL version"

# Test graphics performance
glxgears
```

## Troubleshooting

### Common Issues

#### 1. Build Failures

**Problem:** ISO build fails

```bash
# Check dependencies
pacman -Q archiso squashfs-tools dosfstools libisoburn mtools cdrkit syslinux

# Check disk space
df -h

# Check memory
free -h

# Clean build environment
./build.sh -c
```

#### 2. Boot Failures

**Problem:** ISO doesn't boot

```bash
# Check ISO integrity
file output/arvora-os-*.iso
md5sum output/arvora-os-*.iso

# Test in different environment
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -boot d -cdrom output/arvora-os-*.iso
```

#### 3. Network Issues

**Problem:** No network connectivity

```bash
# Check network interfaces
ip addr show

# Check network services
systemctl status systemd-networkd
systemctl status systemd-resolved

# Check DNS
cat /etc/resolv.conf
nslookup archlinux.org
```

#### 4. Package Issues

**Problem:** Package installation fails

```bash
# Check pacman
pacman -Syy
pacman -S archlinux-keyring

# Check mirrors
reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
```

### Debugging Tools

#### 1. System Logs

```bash
# View system logs
journalctl -f
journalctl -p err
journalctl --since "1 hour ago"

# View boot logs
journalctl -b
```

#### 2. Process Monitoring

```bash
# Monitor processes
htop
iotop
lsof

# Monitor system resources
vmstat 1
iostat 1
```

#### 3. Network Debugging

```bash
# Network debugging
tcpdump -i any
netstat -tuln
ss -tuln
```

## Test Reports

### Report Locations

- **Test reports:** `/tmp/arvora_test_report.txt`
- **Diagnostic reports:** `/tmp/arvora_diagnostics_YYYYMMDD_HHMMSS.txt`
- **Build logs:** `work/build.log`

### Report Analysis

**Test Report Format:**

```
=== Test Results ===
Total Tests: 18
Passed: 18
Failed: 0
Success Rate: 100%

=== Detailed Results ===
PASS:CPU Detection:Found 8 cores - Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz
PASS:Memory Detection:Total RAM: 32GB
...
```

**Diagnostic Report Sections:**

- System Information
- Hardware Information
- Network Information
- Package Management Information
- Service Information
- Process Information
- Log Information
- Security Information
- Performance Information
- Diagnostic Summary

### Report Interpretation

**Success Indicators:**

- All tests pass (100% success rate)
- No failed services
- Normal resource usage
- Successful network connectivity
- Proper hardware detection

**Warning Indicators:**

- Some tests fail (< 100% success rate)
- Failed services present
- High resource usage
- Network connectivity issues
- Hardware detection problems

**Failure Indicators:**

- Many tests fail
- Critical services failed
- System instability
- No network connectivity
- Hardware not detected

## Continuous Integration

### Automated Testing

**GitHub Actions workflow example:**

```yaml
name: Arvora OS Testing

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Install dependencies
        run: |
          sudo pacman -Syu --noconfirm
          sudo pacman -S --noconfirm archiso squashfs-tools dosfstools libisoburn mtools cdrkit syslinux

      - name: Build ISO
        run: ./build.sh -c -t

      - name: Test ISO
        run: |
          # Test ISO integrity
          file output/*.iso
          md5sum -c output/*.md5
          sha256sum -c output/*.sha256

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: arvora-os-iso
          path: output/
```

### Test Automation

**Automated test script:**

```bash
#!/bin/bash
# automated-test.sh

set -e

echo "Starting automated testing..."

# Build the ISO
./build.sh -c -t

# Test the ISO
if [[ -f output/arvora-os-*.iso ]]; then
    echo "ISO build successful"

    # Test ISO integrity
    file output/arvora-os-*.iso
    md5sum -c output/*.md5
    sha256sum -c output/*.sha256

    echo "All tests passed!"
    exit 0
else
    echo "ISO build failed"
    exit 1
fi
```

## Conclusion

This testing framework provides comprehensive validation of Arvora OS functionality, performance, and compatibility. Regular testing ensures the quality and reliability of the distribution.

For additional support or to report issues, please refer to the main README.md file or create an issue in the project repository.

---

**Last updated:** January 2024  
**Version:** 1.0  
**Maintainer:** Dawda Borje Kujabi
