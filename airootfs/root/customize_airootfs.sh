#!/usr/bin/env bash
# Runs inside the ISO rootfs chroot at the end of mkarchiso (see archiso docs).
set -euo pipefail

# Drop releng's root TTY autologin so SDDM + Plasma are the default path.
rm -rf /etc/systemd/system/getty@tty1.service.d

if ! id liveuser &>/dev/null; then
	useradd -m -G wheel,audio,video,optical,storage,network,power -s /bin/bash liveuser
fi

# Empty login password for local session only (ISO); autologin does not need it.
passwd -d liveuser 2>/dev/null || true

mkdir -p /etc/sddm.conf.d
cat >/etc/sddm.conf.d/autologin.conf <<'EOF'
[Autologin]
User=liveuser
Session=plasma-wayland.desktop
EOF

mkdir -p /etc/sudoers.d
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >/etc/sudoers.d/99_wheel_nopasswd
chmod 440 /etc/sudoers.d/99_wheel_nopasswd

systemctl set-default graphical.target
systemctl enable sddm.service
