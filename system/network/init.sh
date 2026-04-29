#!/bin/bash
# =============================================================================
# OpenCode Delivery - Network Initialization Script
# =============================================================================
# Runs on first boot to configure networking, hostname, and SSH
# =============================================================================

set -e

echo "[init.sh] Starting network initialization..."

# =============================================================================
# Configure hostname
# =============================================================================
if [ -n "${OPENCODE_HOSTNAME}" ]; then
    echo "[init.sh] Setting hostname to: ${OPENCODE_HOSTNAME}"
    hostnamectl set-hostname "${OPENCODE_HOSTNAME}"
    echo "127.0.0.1 ${OPENCODE_HOSTNAME}" >> /etc/hosts
fi

# =============================================================================
# Configure DNS
# =============================================================================
if [ -n "${DNS_SERVER}" ]; then
    echo "[init.sh] Configuring DNS server: ${DNS_SERVER}"
    mkdir -p /etc/systemd/resolved.conf.d
    cat > /etc/systemd/resolved.conf.d/custom-dns.conf <<EOF
[Resolve]
DNS=${DNS_SERVER}
DNSStubListener=no
EOF
    systemctl restart systemd-resolved || true
fi

# =============================================================================
# Configure SSH
# =============================================================================
if [ -f "/home/devuser/.ssh/authorized_keys" ]; then
    echo "[init.sh] Setting up SSH authorized keys..."
    mkdir -p /home/devuser/.ssh
    chmod 700 /home/devuser/.ssh
    chown -R devuser:devuser /home/devuser/.ssh
fi

# =============================================================================
# Configure firewall (optional UFW setup)
# =============================================================================
if command -v ufw &> /dev/null; then
    echo "[init.sh] Configuring UFW firewall..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp   # SSH
    ufw allow 80/tcp   # HTTP
    ufw allow 443/tcp  # HTTPS
    ufw allow 4096/tcp  # OpenCode
    ufw --force enable || true
fi

# =============================================================================
# Pre-pull Docker images
# =============================================================================
if command -v docker &> /dev/null; then
    echo "[init.sh] Pre-warming Docker images..."
    docker pull ghcr.io/opencode-ai/opencode:latest || true
    docker pull traefik:v3.2 || true
fi

# =============================================================================
# Start OpenCode service
# =============================================================================
if systemctl is-active --quiet opencode.service; then
    echo "[init.sh] Restarting OpenCode service..."
    systemctl restart opencode.service
else
    echo "[init.sh] Enabling and starting OpenCode service..."
    systemctl enable opencode.service
    systemctl start opencode.service || true
fi

echo "[init.sh] Network initialization complete."
exit 0