#!/usr/bin/env bash
# shellcheck disable=SC2034
# License: FemboyOS Source-Available License v1.0 (BY-NC-NOEDU-NOMED)

iso_name="femboyos"
iso_label="FEMBOYOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="FemboyOS Project (BY-NC-NOEDU-NOMED) <https://github.com/femboyos/femboyos>"
iso_application="FemboyOS Live/Install DVD (Arch + Hyprland Pink Edition)"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux' 'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
    ["/etc/shadow"]="0:0:400"
    ["/root"]="0:0:750"
    ["/root/customize_airootfs.sh"]="0:0:755"
    ["/usr/local/bin/femboy-winrun"]="0:0:755"
)
