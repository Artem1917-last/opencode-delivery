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
# Start services
# =============================================================================
for service in opencode-web.service caddy.service; do
    if systemctl is-enabled --quiet "${service}" 2>/dev/null; then
        echo "[init.sh] Starting ${service}..."
        systemctl start "${service}" || true
    fi
done

echo "[init.sh] Network initialization complete."
exit 0