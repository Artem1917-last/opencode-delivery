#!/bin/bash
# =============================================================================
# OpenCode Delivery - VPS Install Script
# =============================================================================
# One-command install on Ubuntu 22.04 (or any Debian-based Linux)
# Usage: curl -sL https://github.com/Artem1917-last/opencode-delivery/releases/download/v1.0/install.sh | bash
# =============================================================================

set -e

# =============================================================================
# Config
# =============================================================================
RELEASE_VERSION="${RELEASE_VERSION:-v1.0}"
BASE_URL="https://github.com/Artem1917-last/opencode-delivery/releases/download/${RELEASE_VERSION}"

# =============================================================================
# Pre-flight checks
# =============================================================================
if [ "$EUID" -ne 0 ]; then
    echo "Error: run as root (sudo -i)"
    exit 1
fi

echo ""
echo "============================================"
echo "  OpenCode Delivery - Install"
echo "============================================"
echo ""

# =============================================================================
# 1. Create devuser
# =============================================================================
echo "[1/9] Creating devuser..."
id -u devuser &>/dev/null || useradd -m -s /bin/bash -G sudo devuser
echo 'devuser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/devuser
DEVUSER_PASSWORD="${DEVUSER_PASSWORD:-opencode}"
echo "devuser:${DEVUSER_PASSWORD}" | chpasswd
if [ -n "${SSH_PUBLIC_KEY}" ]; then
    mkdir -p /home/devuser/.ssh
    echo "${SSH_PUBLIC_KEY}" >> /home/devuser/.ssh/authorized_keys
    chmod 700 /home/devuser/.ssh
    chmod 600 /home/devuser/.ssh/authorized_keys
    chown -R devuser:devuser /home/devuser/.ssh
fi
echo "[1/9] OK"

# =============================================================================
# 2. Install system packages
# =============================================================================
echo "[2/9] Installing system packages..."
apt-get update -qq
apt-get install -y -qq ufw unzip jq curl wget ca-certificates openssh-server python3 python3-pip
echo "[2/9] OK"

# =============================================================================
# 2b. Disable ispmanager (frees ports 80/443 for Caddy Let's Encrypt)
# =============================================================================
echo "[2.5/9] Disabling ispmanager..."
systemctl stop ispmanager 2>/dev/null || true
systemctl disable ispmanager 2>/dev/null || true
echo "[2.5/9] OK"

# =============================================================================
# 3. Install Node.js
# =============================================================================
echo "[3/9] Installing Node.js..."
if ! command -v node &>/dev/null; then
    wget -q "${BASE_URL}/node-v22.14.0-linux-x64.tar.xz" -O /tmp/node.tar.xz
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1
fi
echo "Node.js: $(node --version)"
echo "[3/9] OK"

# =============================================================================
# 4. Install OpenCode
# =============================================================================
echo "[4/9] Installing OpenCode..."
if ! command -v opencode &>/dev/null; then
    wget -q "${BASE_URL}/opencode-linux-x64.tar.gz" -O /tmp/opencode.tar.gz
    tar -xzf /tmp/opencode.tar.gz -C /tmp
    cp /tmp/opencode /usr/local/bin/opencode
    chmod +x /usr/local/bin/opencode
    rm -f /tmp/opencode /tmp/opencode.tar.gz
fi
echo "OpenCode: $(opencode --version)"
echo "[4/9] OK"

# =============================================================================
# 5. Install Caddy
# =============================================================================
echo "[5/9] Installing Caddy..."
if ! command -v caddy &>/dev/null; then
    wget -q "${BASE_URL}/caddy_2.11.2_linux_amd64.tar.gz" -O /tmp/caddy.tar.gz
    tar -xzf /tmp/caddy.tar.gz -C /tmp
    cp /tmp/caddy /usr/local/bin/caddy
    chmod +x /usr/local/bin/caddy
    rm -f /tmp/caddy /tmp/caddy.tar.gz
    groupadd --system caddy 2>/dev/null || true
    useradd --system --gid caddy --no-create-home --home-dir /var/lib/caddy --shell /usr/sbin/nologin caddy 2>/dev/null || true
fi
echo "Caddy: $(caddy version)"
echo "[5/9] OK"

# =============================================================================
# 6. Extract configs
# =============================================================================
echo "[6/9] Installing configs..."
wget -qO- "${BASE_URL}/configs.tar.gz" | tar xzf - -C /
echo "[6/9] OK"

# =============================================================================
# 7. Create directories and set permissions
# =============================================================================
echo "[7/9] Setting up directories..."
mkdir -p /var/lib/caddy /var/log/caddy /var/lib/opencode-delivery
chown -R caddy:caddy /var/lib/caddy /var/log/caddy
chown -R devuser:devuser /home/devuser
echo "[7/9] OK"

# =============================================================================
# 7.5b. Install npm dependencies for plugins
# =============================================================================
echo "[7.5/9] Installing npm dependencies..."
cd /home/devuser/.opencode
npm install 2>/dev/null || true
cd /
echo "[7.5/9] OK"

# =============================================================================
# 7.6/9. Configure Caddy
# =============================================================================
echo "[7.6/9] Configuring Caddy..."

mkdir -p /etc/caddy

if [ -n "${DOMAIN}" ]; then
    echo "[7.6/9] Domain: ${DOMAIN} — HTTPS with Let's Encrypt"
    cat > /etc/caddy/Caddyfile << 'CADDYEOF'
{$DOMAIN}:443 {
    tls {$LETSENCRYPT_EMAIL}
    reverse_proxy localhost:4096
    header {
        Strict-Transport-Security "max-age=31536000"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        -Server
    }
    log {
        output file /var/log/caddy/opencode-access.log {
            roll_size 100mb
            roll_keep 5
        }
    }
}
CADDYEOF
    echo "DOMAIN=${DOMAIN}" >> /home/devuser/.env
    echo "LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL:-admin@${DOMAIN}}" >> /home/devuser/.env
else
    echo "[7.6/9] No domain — HTTP on :80"
    cat > /etc/caddy/Caddyfile << 'CADDYEOF'
:80 {
    reverse_proxy localhost:4096
    header {
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        -Server
    }
    log {
        output file /var/log/caddy/opencode-access.log {
            roll_size 100mb
            roll_keep 5
        }
    }
}
CADDYEOF
fi
echo "[7.6/9] OK"

# =============================================================================
# 7.7/9. Install MCP dependencies
# =============================================================================
echo "[7.7/9] Installing MCP dependencies..."

npm install -g \
  @modelcontextprotocol/server-filesystem \
  @modelcontextprotocol/server-github \
  @modelcontextprotocol/server-playwright \
  mcp-finder \
  mcp-server-discovery \
  mcp-compass \
  mcp-local-rag \
  node-code-sandbox-mcp \
  2>/dev/null || true

pip3 install \
  google-workspace-mcp \
  telegram-mcp \
  2>/dev/null || true

echo "[7.7/9] OK"

# =============================================================================
# 8. Configure UFW firewall
# =============================================================================
echo "[8/9] Configuring firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

ufw --force enable
ufw status verbose
echo "[8/9] OK"

# =============================================================================
# 9. Enable and start services
# =============================================================================
echo "[9/9] Starting services..."
systemctl daemon-reload
systemctl enable --now sshd || true
systemctl enable opencode-web.service
systemctl enable caddy.service
systemctl start opencode-web.service || true
systemctl start caddy.service || true
echo "[9/9] OK"

# =============================================================================
# Done
# =============================================================================
IP=$(hostname -I | awk '{print $1}')
echo ""
echo "============================================"
echo "  OpenCode установлен!"
echo "============================================"
echo ""
if [ -n "${DOMAIN}" ]; then
    echo "  URL:       https://${DOMAIN}"
else
    echo "  URL:       http://${IP}"
fi
echo "  Login:     admin"
echo "  Password:  admin"
echo ""
echo "  SSH:       ssh devuser@${IP}"
echo "  Password:  ${DEVUSER_PASSWORD:-opencode}"
echo ""
echo "  Config:    /home/devuser/opencode.json"
echo "============================================"
echo ""
