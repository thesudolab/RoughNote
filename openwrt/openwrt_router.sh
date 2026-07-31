cat << 'EOF' > /root/openwrt_config.sh
#!/bin/bin/sh
# ==============================================================================
# OpenWrt Automated Setup Script
# Configures LAN (10.0.2.1/24), WAN DHCP, DHCP Server, and installs LuCI.
# ==============================================================================

echo "--------------------------------------------------------"
echo "[*] Starting OpenWrt Network & LuCI Automated Setup..."
echo "--------------------------------------------------------"

# 1. Configure LAN Interface (10.0.2.1/24)
echo "[*] Setting LAN interface to 10.0.2.1/24..."
uci set network.lan.proto='static'
uci set network.lan.ipaddr='10.0.2.1'
uci set network.lan.netmask='255.255.255.0'

# 2. Configure WAN Interface on eth1
echo "[*] Mapping eth1 to WAN (DHCP)..."
uci set network.wan=interface
uci set network.wan.device='eth1'
uci set network.wan.proto='dhcp'

# 3. Configure LAN DHCP Server (dnsmasq)
echo "[*] Configuring DHCP server range (10.0.2.100 - 10.0.2.250)..."
uci set dhcp.lan.interface='lan'
uci set dhcp.lan.start='100'
uci set dhcp.lan.limit='150'
uci set dhcp.lan.leasetime='12h'

# 4. Commit UCI Changes and Restart Network
echo "[*] Applying network settings..."
uci commit network
uci commit dhcp
/etc/init.d/network restart
/etc/init.d/dnsmasq restart
sleep 3

# 5. Check Internet Reachability
echo "[*] Testing Internet Connectivity..."
if ping -c 2 -W 3 8.8.8.8 >/dev/null 2>&1; then
    echo "[+] Internet connection successful!"
else
    echo "[!] Warning: No internet access on WAN interface yet."
fi

# 6. Update Packages & Install LuCI Web Interface
echo "[*] Updating package index and installing LuCI..."
apk update && apk add luci uhttpd

# 7. Enable and Start uhttpd (Web Server)
echo "[*] Enabling LuCI Web Interface on Port 80..."
/etc/init.d/uhttpd enable
/etc/init.d/uhttpd restart

echo "--------------------------------------------------------"
echo "  [SUCCESS] OpenWrt Configuration Complete!"
echo "  LAN IP: http://10.0.2.1"
echo "--------------------------------------------------------"
EOF
