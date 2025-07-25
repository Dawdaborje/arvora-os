#!/usr/bin/env bash
# shellcheck disable=SC2034

# ISO Configuration
iso_name="arvora-os"
iso_label="ARVORA_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Arvora OS <https://github.com/Dawdaborje/arvora-os>"
iso_application="Arvora OS Live / Experimental Edition"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arvora"

# Build Configuration
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
  'uefi-ia32.systemd-boot.esp' 'uefi-x64.systemd-boot.esp'
  'uefi-ia32.systemd-boot.eltorito' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"

# Optimized Compression Settings
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '19' '-b' '1M' '-Xdict-size' '1M')

# Enhanced Bootstrap Compression
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')

# File Permissions
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/arvora-test"]="0:0:755"
  ["/usr/local/bin/arvora-diagnostics"]="0:0:755"
)
