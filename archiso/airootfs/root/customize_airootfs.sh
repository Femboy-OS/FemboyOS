#!/usr/bin/env bash
# License: FemboyOS Source-Available License v1.0 (BY-NC-NOEDU-NOMED)
set -euo pipefail

# Включение системных сервисов и binfmt-перехватчика .exe
systemctl enable NetworkManager.service
systemctl enable libvirtd.service
systemctl enable systemd-binfmt.service

# Создание live-пользователя astolfo (пароль: femboy)
useradd -m -G wheel,libvirt,kvm,video,audio,input -s /bin/zsh astolfo || true
echo "astolfo:femboy" | chpasswd
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-femboyos

# Клонирование базового конфига end-4/dots-hyprland
git clone --depth=1 https://github.com/end-4/dots-hyprland.git /tmp/dots-hyprland
cp -r /tmp/dots-hyprland/dots/. /etc/skel/
rm -rf /tmp/dots-hyprland

# Подключение розового оверлея и обоев Astolfo GTX 750 BSOD
mkdir -p /etc/skel/.config/hypr
echo "" >> /etc/skel/.config/hypr/hyprland.conf
echo "# FemboyOS Pink & Astolfo BSOD Theme Override" >> /etc/skel/.config/hypr/hyprland.conf
echo "source = ~/.config/hypr/custom/femboy_pink.conf" >> /etc/skel/.config/hypr/hyprland.conf

cp -rT /etc/skel /home/astolfo
chown -R astolfo:astolfo /home/astolfo
