#!/bin/bash
# =============================================================================
# Cleanup Script - Image Freeze Preparation
# =============================================================================
# This script runs at the END of Packer build to prepare the image for
# deployment. It removes build-time artifacts and optimizes size.
#
# Build-time only: Not included in final image
# =============================================================================

set -e

echo "=== Starting image cleanup ==="

# =============================================================================
# 1. Log cleanup
# =============================================================================
echo "Cleaning up logs..."

# Clear systemd journal logs (keep only current)
journalctl --flush 2>/dev/null || true
journalctl --rotate 2>/dev/null || true
journalctl --vacuum-time=1s 2>/dev/null || true
journalctl --vacuum-size=50M 2>/dev/null || true

# Clear apt logs
find /var/log -name "*.log" -type f -exec truncate -s 0 {} \; 2>/dev/null || true

# Clear Debian installer logs
truncate -s 0 /var/log/installer/* 2>/dev/null || true

# =============================================================================
# 2. Package manager cleanup
# =============================================================================
echo "Cleaning up package manager..."

# Remove apt cache
apt-get clean
apt-get autoremove -y
apt-get autoclean -y

# Clear dpkg status of removed packages
dpkg --configure -a || true

# =============================================================================
# 3. User interaction files
# =============================================================================
echo "Removing user interaction files..."

# Remove bash history
rm -f /home/*/.bash_history 2>/dev/null || true
rm -f /root/.bash_history 2>/dev/null || true

# Remove sudo timestamp
rm -f /var/lib/sudo/ts/* 2>/dev/null || true
rm -f /run/sudo/ts/* 2>/dev/null || true

# Remove tmp files
rm -rf /tmp/* 2>/dev/null || true
rm -rf /var/tmp/* 2>/dev/null || true

# Recreate tmp directories with correct permissions
mkdir -p /tmp
chmod 1777 /tmp

mkdir -p /var/tmp
chmod 1777 /var/tmp

# =============================================================================
# 4. Machine-id (will be regenerated on first boot)
# =============================================================================
echo "Resetting machine-id..."

# Create empty machine-id (systemd expects this file)
truncate -s 0 /etc/machine-id

# =============================================================================
# 5. SSH host keys (regenerate on first boot)
# =============================================================================
echo "Preparing SSH host keys for regeneration..."

# Remove SSH host keys (will be regenerated on first boot)
rm -f /etc/ssh/ssh_host_*_key* 2>/dev/null || true

# Create sshd config to regenerate keys on first start
mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/regen-keys.conf << 'EOF'
# Regenerate host keys on first boot
HOSTKEYRegenerate yes
EOF

# =============================================================================
# 6. Network configuration
# =============================================================================
echo "Resetting network configuration..."

# Remove persistent udev rules for network interfaces
rm -f /etc/udev/rules.d/70-persistent-net.rules 2>/dev/null || true
rm -f /etc/udev/rules.d/75-g-cloud-*.rules 2>/dev/null || true

# Keep DHCP configuration for now (client configures static IP at deployment)
# The /etc/network/interfaces.d/static-ip file contains instructions for client

# =============================================================================
# 7. Documentation files (reduce size)
# =============================================================================
echo "Removing unnecessary documentation..."

# Remove man pages (saves ~50MB)
rm -rf /usr/share/man/* 2>/dev/null || true
rm -rf /usr/share/doc/* 2>/dev/null || true
rm -rf /usr/share/doc-base/* 2>/dev/null || true

# Remove localized help
rm -rf /usr/share/locale/* 2>/dev/null || true
rm -rf /usr/share/help/* 2>/dev/null || true

# Remove info pages
rm -rf /usr/share/info/* 2>/dev/null || true

# =============================================================================
# 8. Python cache
# =============================================================================
echo "Cleaning Python cache..."

find /usr -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find /usr -type f -name "*.pyc" -delete 2>/dev/null || true
find /usr -type f -name "*.pyo" -delete 2>/dev/null || true

# =============================================================================
# 9. Docker cleanup (preserve pre-warmed images)
# =============================================================================
echo "Cleaning Docker (preserving pre-warmed images)..."

if command -v docker &> /dev/null; then
    # Stop Docker service
    systemctl stop docker 2>/dev/null || true

    # Remove only build artifacts, containers, and unused images
    # DO NOT prune volumes - they may contain important data
    docker container prune -f 2>/dev/null || true
    docker image prune -f 2>/dev/null || true

    # Clean build cache
    docker builder prune -f 2>/dev/null || true

    # Remove Docker state files but keep images
    rm -f /var/lib/docker/*.db 2>/dev/null || true
    rm -rf /var/lib/docker/network/* 2>/dev/null || true
fi

# =============================================================================
# 10. First boot marker
# =============================================================================
echo "Creating first boot marker..."

mkdir -p /var/lib/opencode-delivery
date > /var/lib/opencode-delivery/first-boot-marker
echo "PACKER_BUILD=COMPLETE" >> /var/lib/opencode-delivery/first-boot-marker

# =============================================================================
# 11. Final sync
# =============================================================================
echo "Syncing filesystems..."

sync
sync
sync

# =============================================================================
# 12. Zero free space (optional, enables better compression)
# =============================================================================
echo "Zeroing free space (this may take a while)..."

# Fill free space with zeros (helps with qcow2 compression)
dd if=/dev/zero of=/var/tmp/fill bs=1M status=progress 2>/dev/null || true
rm -f /var/tmp/fill

# =============================================================================
# Done
# =============================================================================
echo "=== Image cleanup complete ==="
echo "Image is ready for deployment."
