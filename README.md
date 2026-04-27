# Arvora OS

Personal Arch-based distro experiment for learning—not for production. Experimental and unstable; use at your own risk.

The flagship image is a **KDE Plasma** live session (SDDM autologin as `liveuser`) with the **Calamares** graphical installer (unpackfs-based install). Build that variant with [`build_with_calamares.sh`](build_with_calamares.sh); the ISO is written under `out/calamares/` by default.

## Build

Requires Arch (or Arch-based), ~10 GB disk, 6+ GB RAM recommended for live Plasma, network:

```bash
sudo pacman -S archiso squashfs-tools dosfstools libisoburn mtools cdrkit syslinux

git clone https://github.com/Dawdaborje/arvora-os.git && cd arvora-os

chmod +x build.sh build_with_calamares.sh scripts/setup_calamares.sh

./build_with_calamares.sh -t        # Plasma + Calamares → out/calamares/
./build.sh -c -t                     # alternate: plain ISO → output/

qemu-system-x86_64 -enable-kvm -m 6G -smp 4 -boot d -cdrom out/calamares/arvora-os-*.iso
```

Related components and apps live on [separate branches](https://github.com/Dawdaborje/arvora-os) on GitHub.

## Docs

- [docs/QUICKSTART.md](docs/QUICKSTART.md) — setup and options  
- [docs/TESTING.md](docs/TESTING.md) — tests and tooling  
- `./build.sh --help`

## Author & license

**Dawda Borje Kujabi** — [GitHub](https://github.com/Dawdaborje). Licensed under [LICENSE](LICENSE).
