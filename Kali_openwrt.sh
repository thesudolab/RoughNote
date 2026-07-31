#!/usr/bin/env bash
# ==============================================================================
# OpenWrt Network Auto-Configurator for Kali Linux
# Sets up static IP routing, updates DNS, and broadcasts ARP requests.
# ==============================================================================

# Ensure script runs as root
if [ "$EUID" -ne 0 ]; then
  echo "[!] Please run as root (use sudo)."
  exit 1
fi

INTERFACE="eth0"
OPENWRT_IP="10.0.2.1"
KALI_IP="10.0.2.15/24"

echo "[*] Initializing network configuration on $INTERFACE..."

# 1. Reset interface and assign IP
ip addr flush dev "$INTERFACE"
ip addr add "$KALI_IP" dev "$INTERFACE"
ip link set "$INTERFACE" up
echo "[+] Assigned IP $KALI_IP to $INTERFACE"

# 2. Add default gateway pointing to OpenWrt
ip route add default via "$OPENWRT_IP"
echo "[+] Set default gateway to $OPENWRT_IP"

# 3. Configure DNS resolver
echo "nameserver $OPENWRT_IP" > /etc/resolv.conf
echo "[+] Set DNS resolver to $OPENWRT_IP"

# 4. Critical ARP Broadcast (Resolves virtual switch stale routes)
echo "[*] Broadcasting ARP request to discover OpenWrt ($OPENWRT_IP)..."
arping -c 3 -I "$INTERFACE" "$OPENWRT_IP" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "[+] ARP resolution successful! OpenWrt is reachable."
else
    echo "[!] Warning: ARP broadcast received no reply. Check VM settings."
fi

# 5. Test Port 80 Access
echo "[*] Testing connection to LuCI Web Portal (port 80)..."
if nc -zv -w 3 "$OPENWRT_IP" 80 > /dev/null 2>&1; then
    echo "========================================================"
    echo "  SUCCESS! OpenWrt is fully reachable."
    echo "  Open Firefox and go to: http://$OPENWRT_IP"
    echo "========================================================"
else
    echo "[!] Connection refused or timed out on port 80."
fi
