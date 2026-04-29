# OpenCode Delivery

Pre-configured OpenCode AI coding agent with Traefik reverse proxy, ready for deployment on FirstVDS or any KVM-based VPS.

## Features

- **OpenCode AI Agent** - AI-powered coding assistant
- **Traefik v3** - Reverse proxy with automatic HTTPS (Let's Encrypt)
- **Basic Auth** - Password-protected access
- **Rate Limiting** - 10 req/sec to prevent brute force
- **144 Agency Agents** - Pre-installed professional agents
- **MCP Servers** - Pre-configured for filesystem, GitHub, and more
- **Local Documentation** - olore-opencode skill included

## Quick Start

### Prerequisites

- Ubuntu 24.04 LTS (installed via Packer image)
- Docker & Docker Compose
- Ports 80, 31415 open

### Installation

1. **Deploy the Packer image** to your VPS:
   ```bash
   # Build the image
   cd packer
   packer init .
   packer build -var="ssh_password=YOUR_SSH_PASSWORD" template.pkr.hcl

   # Deploy to FirstVDS
   qemu-img convert -O qcow2 output-ubuntu2404/opencode-ubuntu2404.qcow2 \
     /path/to/vps/image.qcow2
   ```

2. **Start the services**:
   ```bash
   cd /home/devuser/opencode-delivery
   docker-compose up -d
   ```

3. **Get your credentials**:
   ```bash
   cat /var/log/first-boot.log
   ```

4. **Access OpenCode**:
   - URL: `https://YOUR_SERVER_IP:31415`
   - Username: `devuser`
   - Password: (from first-boot.log)

## Configuration

### Environment Variables

Create a `.env` file:

```bash
# OpenCode credentials
OPENCODE_USERNAME=devuser
OPENCODE_PASSWORD=your_secure_password_here

# AI Provider (optional)
OPENCODE_AUTH_PROVIDER=antigravity
OPENCODE_AUTH_API_KEY=your_api_key
```

### Traefik Configuration

Edit `traefik/dynamic.yml` to change:
- Basic Auth password
- Rate limits
- TLS settings

### Docker Compose Profiles

```bash
# Start all services
docker-compose up -d

# Start only OpenCode (without Traefik)
docker-compose --profile production up -d opencode

# Stop all services
docker-compose down
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        VPS                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Traefik (Port 31415)                   │    │
│  │  ┌─────────────┐  ┌──────────────┐  ┌────────────┐  │    │
│  │  │ Rate Limit  │  │ Basic Auth   │  │ Let's      │  │    │
│  │  │ 10 req/sec  │  │ Password     │  │ Encrypt    │  │    │
│  │  └─────────────┘  └──────────────┘  └────────────┘  │    │
│  └──────────────────────┬──────────────────────────────┘    │
│                         │                                   │
│                    ┌────▼────┐                              │
│                    │ OpenCode│ Port 4096                    │
│                    └────┬────┘                              │
│                         │                                   │
│  ┌──────────────────────▼──────────────────────────────┐  │
│  │              Docker Volumes                           │  │
│  │  • opencode-data     • opencode-config               │  │
│  │  • opencode-state    • traefik-certs                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Host Files (Read-only)                  │    │
│  │  • /home/devuser/configs/agents                     │    │
│  │  • /home/devuser/configs/skills                     │    │
│  │  • /home/devuser/configs/mcp                        │    │
│  │  • /home/devuser/configs/plugins                     │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
opencode-delivery/
├── packer/                    # Packer templates for image building
├── scripts/packer/            # Build-time scripts (preseed, cleanup)
├── system/                   # Root-space configurations
│   ├── traefik/              # Traefik v3 configs
│   ├── systemd/              # Systemd unit files
│   └── network/             # Network initialization
├── home/devuser/             # User-space (devuser owner)
│   ├── configs/             # Agent, skill, MCP, plugin configs
│   └── opencode-delivery/   # Docker Compose setup
└── plans/                    # Architecture Decision Records
```

## Security

### Port 80 (ACME Challenge)

Port 80 **must** be open for Let's Encrypt certificate renewal:
```bash
ufw allow 80/tcp
ufw allow 31415/tcp
```

### Basic Auth

Change the default password in `traefik/dynamic.yml`:
```bash
# Generate new password
htpasswd -nb admin NEW_PASSWORD | tr -d '\n'
```

### Rate Limiting

Current limits:
- Average: 10 requests/sec
- Burst: 50
- Period: 1s

## Maintenance

### Update OpenCode
```bash
docker-compose pull opencode
docker-compose up -d opencode
```

### Update Traefik
```bash
docker-compose pull traefik
docker-compose up -d traefik
```

### Backup Data
```bash
docker-compose stop
tar -czf backup-$(date +%Y%m%d).tar.gz \
  -C /home/devuser opencode-delivery/
docker-compose start
```

### View Logs
```bash
# Traefik logs
docker-compose logs -f traefik

# OpenCode logs
docker-compose logs -f opencode

# System logs
journalctl -u opencode.service -f
```

## Troubleshooting

### OpenCode won't start
```bash
# Check logs
docker-compose logs opencode

# Verify volume permissions
ls -la /home/devuser/

# Restart service
systemctl restart opencode
```

### Can't access HTTPS
```bash
# Check Traefik logs
docker-compose logs traefik

# Verify ports
ss -tlnp | grep -E '80|31415'

# Check firewall
ufw status
```

### Let's Encrypt not working
```bash
# Check certificate status
docker-compose exec traefik ls -la /letsencrypt/

# Force certificate renewal
docker-compose exec traefik traefik healthcheck --ping
```

## License

MIT License - See LICENSE file for details.

## Support

- Documentation: https://opencode.ai/docs
- GitHub Issues: https://github.com/opencode-ai/opencode/issues
