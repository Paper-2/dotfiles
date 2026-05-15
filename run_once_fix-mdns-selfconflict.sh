#!/bin/sh
# Fix systemd-resolved mDNS self-conflict (hostname rename on boot)
# Delegates mDNS announcements to avahi-daemon; resolved keeps resolve-only mode.

# 1. Install avahi + nss-mdns if missing
pacman -Qq avahi nss-mdns &>/dev/null || sudo pacman -S --noconfirm avahi nss-mdns

# 2. Set resolved to resolve-only mDNS (avahi handles announcements)
grep -q '^MulticastDNS=resolve' /etc/systemd/resolved.conf || \
  sudo sed -i 's/^#\?MulticastDNS=.*/MulticastDNS=resolve/' /etc/systemd/resolved.conf

# 3. Update nsswitch.conf for mdns_minimal resolution
grep -q 'mdns_minimal' /etc/nsswitch.conf || \
  sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files dns/' /etc/nsswitch.conf

# 4. Enable avahi and restart resolved
sudo systemctl enable --now avahi-daemon
sudo systemctl restart systemd-resolved
