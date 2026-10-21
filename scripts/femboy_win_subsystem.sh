#!/usr/bin/env bash
# ==============================================================================
# FemboyOS Windows 7 / Windows 10 PE Subsystem Integration Module
# (No Wine / No Proton — Direct binfmt_misc PE Hook + KVM/FreeRDP & WRK Reference)
# SPDX-License-Identifier: Unlicense (Public Domain)
# ==============================================================================
set -euo pipefail

SUBSYSTEM_DIR="/opt/femboyos-win-subsystem"
WRK_REPO="https://github.com/GIJoes/WINDOWSCODES.git"
WIN7_REPO="https://github.com/jkalter11/windows-7-sources.git"

echo "[*] Initializing FemboyOS Windows 7/10 Subsystem (Zero Wine / Zero Proton)..."
mkdir -p "${SUBSYSTEM_DIR}/sources" "${SUBSYSTEM_DIR}/bin"

# 1. Fetch & Verify Referenced Repositories (Optional Reference / Header Extraction)
if [ "${FETCH_REFERENCE_REPOS:-0}" = "1" ]; then
    echo "[*] Cloning reference repositories into ${SUBSYSTEM_DIR}/sources..."
    git clone --depth=1 "${WRK_REPO}" "${SUBSYSTEM_DIR}/sources/wrk-ntos" || true
    git clone --depth=1 "${WIN7_REPO}" "${SUBSYSTEM_DIR}/sources/win7-tree" || true
fi

# 2. Install Rootless PE (.exe) Launcher via KVM + FreeRDP RemoteApp
cat << 'EOF' > /usr/local/bin/femboy-winrun
#!/usr/bin/env bash
# ==============================================================================
# femboy-winrun: Execute Windows 7 & Windows 10 PE (.exe) binaries natively
# on Arch Linux + Hyprland via KVM Micro-VM & FreeRDP RemoteApp (No Wine/Proton)
# SPDX-License-Identifier: Unlicense
# ==============================================================================
set -euo pipefail

RDP_USER="${FEMBOY_WIN_USER:-astolfo}"
RDP_PASS="${FEMBOY_WIN_PASS:-femboyos}"
RDP_IP="${FEMBOY_WIN_IP:-192.168.122.50}"
VM_NAME="${FEMBOY_WIN_VM:-femboy-win10-ltsc}"
TARGET_EXE="${1:-explorer.exe}"

# Ensure the KVM backend guest is running
if command -v virsh >/dev/null 2>&1; then
    if ! virsh list --name | grep -q "^${VM_NAME}$"; then
        echo "[FemboyOS PE Loader] Booting KVM Windows guest (${VM_NAME})..."
        virsh start "${VM_NAME}" >/dev/null 2>&1 || true
    fi
fi

# Map host Linux path to shared VirtIO-FS / SMB mount (\\tsclient\root) if local file passed
if [ -f "${TARGET_EXE}" ]; then
    ABS_PATH="$(realpath "${TARGET_EXE}")"
    WIN_PATH="\\\\tsclient\\root${ABS_PATH//\//\\}"
else
    WIN_PATH="${TARGET_EXE}"
fi

exec xfreerdp3 \
    /v:"${RDP_IP}" \
    /u:"${RDP_USER}" \
    /p:"${RDP_PASS}" \
    /app:program:"${WIN_PATH}" \
    /drive:root,/ \
    /dynamic-resolution \
    +clipboard \
    /sound:sys:pulse \
    /microphone:sys:pulse \
    /cert:ignore \
    /wm-class:"femboyos-winapp"
EOF
chmod +x /usr/local/bin/femboy-winrun

# 3. Register Linux Kernel binfmt_misc Handler for Windows PE ('MZ') Binaries
mkdir -p /etc/binfmt.d
cat << 'EOF' > /etc/binfmt.d/femboyos-windows-pe.conf
:FEMBOYOS_PE:M::MZ::/usr/local/bin/femboy-winrun:OC
EOF

if [ -f /proc/sys/fs/binfmt_misc/register ]; then
    systemctl restart systemd-binfmt.service || true
fi

echo "[+] FemboyOS Windows PE Subsystem installed and registered with systemd-binfmt!"
