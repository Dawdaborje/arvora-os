#!/bin/bash
# Arvora OS Calamares Setup Script
# This script sets up Calamares integration for Arvora OS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "profiledef.sh" ]]; then
    print_error "This script must be run from the Arvora OS root directory"
    exit 1
fi

print_status "Setting up Calamares integration for Arvora OS..."

# Create necessary directories
print_status "Creating Calamares directories..."
mkdir -p airootfs/etc/calamares/modules
mkdir -p airootfs/etc/calamares/branding/arvora
mkdir -p airootfs/usr/share/calamares/branding/arvora
mkdir -p airootfs/usr/share/calamares/modules

# Copy Calamares configuration files
print_status "Copying Calamares configuration files..."

# Copy the polkit script and make it executable
if [[ -f "airootfs/usr/bin/calamares_polkit" ]]; then
    chmod +x airootfs/usr/bin/calamares_polkit
    print_success "Calamares polkit script is executable"
fi

# Copy the polkit rules
if [[ -f "airootfs/etc/polkit-1/rules.d/49-nopasswd-calamares.rules" ]]; then
    print_success "Polkit rules copied"
fi

# Copy the desktop entry
if [[ -f "airootfs/etc/xdg/autostart/calamares.desktop" ]]; then
    print_success "Desktop entry copied"
fi

# Copy Calamares configuration
if [[ -f "airootfs/etc/calamares/settings.conf" ]]; then
    print_success "Calamares settings copied"
fi

# Copy branding files
if [[ -f "airootfs/etc/calamares/branding/arvora/branding.desc" ]]; then
    print_success "Branding configuration copied"
fi

# Copy module configurations
for config in welcome.conf packages.conf bootloader.conf unpackfs.conf; do
    if [[ -f "airootfs/etc/calamares/modules/$config" ]]; then
        print_success "Module config $config copied"
    fi
done

# Create additional module configurations
print_status "Creating additional module configurations..."

# Users module
cat > airootfs/etc/calamares/modules/users.conf << 'EOF'
---
# Arvora OS Users Module Configuration
# This file configures user creation during installation

# Default user settings
defaultGroups:
  - users
  - wheel
  - storage
  - power
  - network
  - video
  - audio
  - optical
  - lp
  - scanner

# Autologin group
autologinGroup: "autologin"

# Do not reuse passwords for the root account
setRootPassword: true

# Do not allow empty passwords
allowWeakPasswords: false

# Hostname
hostname: "arvora"

# Hostname template
hostnameTemplate: "arvora-{hostname}"
EOF

# Locale module
cat > airootfs/etc/calamares/modules/locale.conf << 'EOF'
---
# Arvora OS Locale Module Configuration
# This file configures locale settings during installation

# Default locale
locale: "en_US.UTF-8"

# Default timezone
timezone: "UTC"

# Default keyboard layout
keyboardLayout: "us"

# Default keyboard variant
keyboardVariant: ""

# Default keyboard model
keyboardModel: ""

# GeoIP URL for automatic timezone detection
geoipUrl: "https://geoip.kde.org/v1/calamares"
EOF

# Partition module
cat > airootfs/etc/calamares/modules/partition.conf << 'EOF'
---
# Arvora OS Partition Module Configuration
# This file configures disk partitioning during installation

# Default filesystem
defaultFileSystemType: "ext4"

# Available filesystem types
availableFileSystemTypes:
  - "ext4"
  - "ext3"
  - "ext2"
  - "btrfs"
  - "xfs"
  - "jfs"
  - "reiserfs"
  - "f2fs"

# EFI system partition
efiSystemPartition: "/boot/efi"

# Swap partition
swapPartitionChoices:
  - "none"
  - "small"
  - "suspend"
  - "file"

# Default swap size (in GiB)
swapSize: 2.0

# Always show advanced partitioning
alwaysShowPartitionLabels: true

# Allow manual partitioning
allowManualPartitioning: true

# Allow manual encryption
allowManualEncryption: true

# Initial partitioning setup
initialPartitioningChoice: "replace"
EOF

# Summary module
cat > airootfs/etc/calamares/modules/summary.conf << 'EOF'
---
# Arvora OS Summary Module Configuration
# This file configures the summary page before installation

# Show partition summary
showPartitionSummary: true

# Show user summary
showUserSummary: true

# Show package summary
showPackageSummary: true

# Show bootloader summary
showBootloaderSummary: true

# Show network summary
showNetworkSummary: true

# Show locale summary
showLocaleSummary: true

# Show keyboard summary
showKeyboardSummary: true

# Show timezone summary
showTimezoneSummary: true
EOF

# Machine ID module
cat > airootfs/etc/calamares/modules/machineid.conf << 'EOF'
---
# Arvora OS Machine ID Module Configuration
# This file configures machine ID generation

# Systemd machine ID
systemd: true

# DBUS machine ID
dbus: true

# Symlink to /etc/machine-id
symlink: true
EOF

# Fstab module
cat > airootfs/etc/calamares/modules/fstab.conf << 'EOF'
---
# Arvora OS Fstab Module Configuration
# This file configures /etc/fstab generation

# Generate fstab
generateFstab: true

# Mount options
mountOptions:
  - "defaults"
  - "noatime"
  - "nodiratime"

# Swap mount options
swapMountOptions:
  - "defaults"
  - "sw"
EOF

# Localecfg module
cat > airootfs/etc/calamares/modules/localecfg.conf << 'EOF'
---
# Arvora OS Locale Configuration Module
# This file configures locale settings

# Locale configuration file
localeGenPath: "/etc/locale.gen"

# Locale configuration
localeConfPath: "/etc/locale.conf"

# Locale settings
localeSettingsPath: "/etc/default/locale"

# Write locale configuration
writeLocaleConf: true

# Write locale settings
writeLocaleSettings: true
EOF

# Initcpio module
cat > airootfs/etc/calamares/modules/initcpio.conf << 'EOF'
---
# Arvora OS Initcpio Module Configuration
# This file configures initramfs generation

# Initcpio configuration file
configFile: "/etc/mkinitcpio.conf"

# Initcpio preset
presetFile: "/etc/mkinitcpio.d/linux.preset"

# Generate initramfs
generateInitramfs: true

# Initramfs hooks
hooks:
  - "base"
  - "udev"
  - "autodetect"
  - "modconf"
  - "block"
  - "filesystems"
  - "keyboard"
  - "fsck"

# Initramfs modules
modules:
  - "ext4"
  - "btrfs"
  - "xfs"
  - "jfs"
  - "reiserfs"
  - "f2fs"

# Initramfs binaries
binaries:
  - "/usr/bin/btrfs"
  - "/usr/bin/btrfsck"
  - "/usr/bin/btrfs-show-super"
  - "/usr/bin/btrfstune"
  - "/usr/bin/btrfs-zero-log"
  - "/usr/bin/btrfs-image"
  - "/usr/bin/btrfs-find-root"
  - "/usr/bin/btrfs-select-super"
  - "/usr/bin/btrfs-corrupt-block"
  - "/usr/bin/btrfs-check"
  - "/usr/bin/btrfs-restore"
  - "/usr/bin/btrfs-send"
  - "/usr/bin/btrfs-receive"
  - "/usr/bin/btrfs-subvolume"
  - "/usr/bin/btrfs-filesystem"
  - "/usr/bin/btrfs-balance"
  - "/usr/bin/btrfs-scrub"
  - "/usr/bin/btrfs-quota"
  - "/usr/bin/btrfs-qgroup"
  - "/usr/bin/btrfs-inspect-internal"
  - "/usr/bin/btrfs-map-logical"
  - "/usr/bin/btrfs-show-blocks"
  - "/usr/bin/btrfs-show-super"
  - "/usr/bin/btrfs-zero-log"
  - "/usr/bin/btrfs-image"
  - "/usr/bin/btrfs-find-root"
  - "/usr/bin/btrfs-select-super"
  - "/usr/bin/btrfs-corrupt-block"
  - "/usr/bin/btrfs-check"
  - "/usr/bin/btrfs-restore"
  - "/usr/bin/btrfs-send"
  - "/usr/bin/btrfs-receive"
  - "/usr/bin/btrfs-subvolume"
  - "/usr/bin/btrfs-filesystem"
  - "/usr/bin/btrfs-balance"
  - "/usr/bin/btrfs-scrub"
  - "/usr/bin/btrfs-quota"
  - "/usr/bin/btrfs-qgroup"
  - "/usr/bin/btrfs-inspect-internal"
  - "/usr/bin/btrfs-map-logical"
  - "/usr/bin/btrfs-show-blocks"
EOF

# Network configuration module
cat > airootfs/etc/calamares/modules/networkcfg.conf << 'EOF'
---
# Arvora OS Network Configuration Module
# This file configures network settings

# Network configuration
configFile: "/etc/systemd/network/20-wired.network"

# Network manager
networkManager: "systemd-networkd"

# Network configuration
networkConfiguration:
  - interface: "*"
    dhcp: true
    dns:
      - "8.8.8.8"
      - "8.8.4.4"
      - "1.1.1.1"
      - "1.0.0.1"
EOF

# Hardware clock module
cat > airootfs/etc/calamares/modules/hwclock.conf << 'EOF'
---
# Arvora OS Hardware Clock Module Configuration
# This file configures hardware clock settings

# Hardware clock
hwclock: "UTC"

# NTP synchronization
ntp: true

# NTP servers
ntpServers:
  - "pool.ntp.org"
  - "time.nist.gov"
  - "time.windows.com"
EOF

# Services module
cat > airootfs/etc/calamares/modules/services-systemd.conf << 'EOF'
---
# Arvora OS Services Module Configuration
# This file configures systemd services

# Services to enable
services:
  - "NetworkManager"
  - "systemd-resolved"
  - "systemd-timesyncd"
  - "bluetooth"
  - "cups"
  - "avahi-daemon"
  - "sshd"
  - "fstrim.timer"
  - "pkgfile-update.timer"
  - "reflector.timer"

# Services to disable
disable:
  - "systemd-networkd"
  - "systemd-networkd-wait-online"
EOF

# Umount module
cat > airootfs/etc/calamares/modules/umount.conf << 'EOF'
---
# Arvora OS Umount Module Configuration
# This file configures unmounting of target system

# Unmount target
unmount: true

# Unmount options
unmountOptions:
  - "lazy"
  - "force"

# Unmount timeout
unmountTimeout: 30
EOF

print_success "All Calamares module configurations created"

# Create a simple QML slideshow
print_status "Creating Calamares slideshow..."

cat > airootfs/usr/share/calamares/branding/arvora/slideshow.qml << 'EOF'
import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    function onActivate() {
        console.log("QML Component (default slideshow) activated");
        presentation.nextSlide();
    }

    Timer {
        id: advanceTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: presentation.nextSlide()
    }

    Slide {
        anchors.fill: parent
        anchors.verticalCenterOffset: 0

        Image {
            id: background
            anchors.fill: parent
            source: "slide1.png"
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: background.bottom
            text: qsTr("Welcome to Arvora OS", "main title")
            wrapMode: Text.WordWrap
            width: root.width
            horizontalAlignment: Text.Center
        }
    }

    Slide {
        anchors.fill: parent
        anchors.verticalCenterOffset: 0

        Image {
            id: background2
            anchors.fill: parent
            source: "slide2.png"
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: background2.bottom
            text: qsTr("Installing Arvora OS...", "main title")
            wrapMode: Text.WordWrap
            width: root.width
            horizontalAlignment: Text.Center
        }
    }

    Slide {
        anchors.fill: parent
        anchors.verticalCenterOffset: 0

        Image {
            id: background3
            anchors.fill: parent
            source: "slide3.png"
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: background3.bottom
            text: qsTr("Installation Complete!", "main title")
            wrapMode: Text.WordWrap
            width: root.width
            horizontalAlignment: Text.Center
        }
    }
}
EOF

# Create a simple CSS style
cat > airootfs/usr/share/calamares/branding/arvora/style.qss << 'EOF'
/* Arvora OS Calamares Style */

QWidget {
    background-color: #2b2b2b;
    color: #ffffff;
    font-family: "Noto Sans", "DejaVu Sans", sans-serif;
    font-size: 10pt;
}

QPushButton {
    background-color: #3c3c3c;
    border: 1px solid #555555;
    border-radius: 4px;
    padding: 8px 16px;
    color: #ffffff;
    font-weight: bold;
}

QPushButton:hover {
    background-color: #4c4c4c;
    border-color: #666666;
}

QPushButton:pressed {
    background-color: #2c2c2c;
    border-color: #444444;
}

QPushButton:disabled {
    background-color: #1c1c1c;
    color: #666666;
    border-color: #333333;
}

QLabel {
    color: #ffffff;
}

QLineEdit {
    background-color: #3c3c3c;
    border: 1px solid #555555;
    border-radius: 4px;
    padding: 6px;
    color: #ffffff;
}

QLineEdit:focus {
    border-color: #0078d4;
}

QComboBox {
    background-color: #3c3c3c;
    border: 1px solid #555555;
    border-radius: 4px;
    padding: 6px;
    color: #ffffff;
}

QComboBox:drop-down {
    border: none;
    width: 20px;
}

QComboBox:down-arrow {
    image: url(down-arrow.png);
    width: 12px;
    height: 12px;
}

QComboBox QAbstractItemView {
    background-color: #3c3c3c;
    border: 1px solid #555555;
    selection-background-color: #0078d4;
    color: #ffffff;
}

QProgressBar {
    border: 1px solid #555555;
    border-radius: 4px;
    text-align: center;
    background-color: #3c3c3c;
}

QProgressBar::chunk {
    background-color: #0078d4;
    border-radius: 3px;
}

QTextEdit {
    background-color: #3c3c3c;
    border: 1px solid #555555;
    border-radius: 4px;
    color: #ffffff;
}

QTreeView {
    background-color: #3c3c3c;
    border: 1px solid #555555;
    color: #ffffff;
}

QTreeView::item {
    padding: 4px;
}

QTreeView::item:selected {
    background-color: #0078d4;
}

QHeaderView::section {
    background-color: #2c2c2c;
    border: 1px solid #555555;
    padding: 6px;
    color: #ffffff;
    font-weight: bold;
}

QScrollBar:vertical {
    background-color: #3c3c3c;
    width: 12px;
    border-radius: 6px;
}

QScrollBar::handle:vertical {
    background-color: #555555;
    border-radius: 6px;
    min-height: 20px;
}

QScrollBar::handle:vertical:hover {
    background-color: #666666;
}

QScrollBar::add-line:vertical,
QScrollBar::sub-line:vertical {
    height: 0px;
}

QScrollBar:horizontal {
    background-color: #3c3c3c;
    height: 12px;
    border-radius: 6px;
}

QScrollBar::handle:horizontal {
    background-color: #555555;
    border-radius: 6px;
    min-width: 20px;
}

QScrollBar::handle:horizontal:hover {
    background-color: #666666;
}

QScrollBar::add-line:horizontal,
QScrollBar::sub-line:horizontal {
    width: 0px;
}
EOF

print_success "Calamares slideshow and style created"

# Update the profiledef.sh to include Calamares
print_status "Updating profiledef.sh to include Calamares..."

# Add Calamares to the packages list
if ! grep -q "calamares" packages.x86_64; then
    echo "calamares" >> packages.x86_64
    print_success "Added calamares to packages list"
fi

# Add Calamares dependencies
for pkg in "qt6-base" "qt6-svg" "kconfig" "kcoreaddons" "ki18n" "kiconthemes" "kio" "solid" "polkit-qt6" "yaml-cpp" "ckbcomp" "efibootmgr" "gtk-update-icon-cache" "hwinfo" "icu" "kpmcore" "libpwquality" "mkinitcpio-openswap" "squashfs-tools"; do
    if ! grep -q "$pkg" packages.x86_64; then
        echo "$pkg" >> packages.x86_64
        print_success "Added $pkg to packages list"
    fi
done

print_success "Calamares integration setup complete!"

print_status "Next steps:"
print_status "1. Build Arvora OS with: ./build.sh -c -t"
print_status "2. Test the ISO with QEMU"
print_status "3. Calamares will start automatically on first boot"

print_success "Setup complete!" 