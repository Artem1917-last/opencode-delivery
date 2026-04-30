# OpenCode Delivery — Technical Documentation

## Concept

Ready-to-use solution for micro-business automation. Client creates a VDS, we install OpenCode in Docker — client logs in and starts working. No terminal skills required.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  Delivery Flow                      │
├─────────────────────────────────────────────────────┤
│ STAGE 1: Prepare (one-time, operator machine)       │
│   prepare.sh → fork repo, install agents, configs   │
├─────────────────────────────────────────────────────┤
│ STAGE 2: Build VM Image (Packer + QEMU)             │
│   template.pkr.hcl → .qcow2 image for FirstVDS      │
├─────────────────────────────────────────────────────┤
│ STAGE 3: Install on VPS (one-time)                   │
│   install-vps.sh → Docker + Traefik + containers     │
├─────────────────────────────────────────────────────┤
│ STAGE 4: Onboard Client                              │
│   onboard-client.sh → credentials + docs            │
└─────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
opencode-delivery/
├── ADRs/                              # Architecture Decision Records
│   └── 001-architecture-decisions.md  # 10 key decisions
├── configs/                           # Central configuration hub
│   ├── agents/                        # 144 AI agents (12 divisions)
│   │   ├── engineering/              # 30+ agents
│   │   ├── design/                  # 8 agents
│   │   ├── marketing/               # 27 agents
│   │   ├── sales/                   # 9 agents
│   │   ├── specialized/             # 30+ agents
│   │   ├── project-management/      # 6 agents
│   │   ├── testing/                 # 8 agents
│   │   ├── support/                 # 7 agents
│   │   ├── paid-media/              # 7 agents
│   │   ├── product/                # 5 agents
│   │   ├── finance/                 # 5 agents
│   │   └── game-development/        # 20+ agents
│   ├── skills/                       # OpenCode skills
│   │   ├── mcp-finder/             # MCP server discovery (6,700+ indexed)
│   │   ├── agent-memory/           # Session context memory
│   │   ├── opencode-skill-generator/# Config generator for OpenCode
│   │   └── olore-opencode-latest/  # Local OpenCode documentation
│   ├── mcp/                          # MCP server configs (empty dirs)
│   ├── opencode/                    # Main OpenCode config
│   │   └── opencode.json            # JSON schema config
│   ├── traefik/                     # Traefik v3 reverse proxy
│   │   ├── dynamic.yml             # HTTP routing, Basic Auth, Rate Limit
│   │   ├── tls.yml                 # Let's Encrypt ACME
│   │   ├── auth/htpasswd           # Basic Auth password file
│   │   ├── acme/acme.json          # Let's Encrypt certificates
│   │   └── certs/                  # TLS placeholder certs
│   ├── plugins/                     # Plugin configs (empty)
│   └── env.example                  # Environment template
├── documentation/                    # Client-facing docs (empty, built at onboard)
├── home/                             # User-space files (embedded in VM)
│   └── devuser/
│       ├── configs/                  # Symlinks to configs/
│       └── opencode-delivery/        # Docker Compose production
│           ├── docker-compose.yml   # Production compose
│           └── Dockerfile          # Pre-built image
├── packer/                          # Packer VM builder
│   └── template.pkr.hcl             # QEMU builder for Debian 12
├── scripts/                         # Installation scripts
│   ├── prepare.sh                   # Stage 1: fork repo, install agents
│   ├── install-vps.sh               # Stage 2: Docker + Traefik setup
│   ├── onboard-client.sh            # Stage 3: generate credentials
│   ├── generate-password.sh         # 14-char password generator
│   └── packer/                     # Packer build-time scripts
│       ├── preseed.cfg             # Debian 12 automated install
│       └── cleanup.sh             # Image freeze (logs, cache, SSH keys)
├── system/                          # Root-space configs (embedded in VM)
│   ├── systemd/
│   │   └── opencode.service        # Systemd unit for Docker Compose
│   ├── network/
│   │   └── init.sh                 # First-boot network/SSH/firewall
│   └── traefik/                    # System-level Traefik configs
├── Dockerfile                       # Main Docker image (Ubuntu 24.04 + OpenCode)
├── docker-compose.yml               # Development compose (single host)
└── README.md                        # Main documentation (Russian)
```

---

## Data Layering

### Build-time only (`scripts/packer/`)

Files needed only for Packer image creation. Deleted after assembly.

| File | Purpose |
|------|---------|
| `preseed.cfg` | Debian automated install answers |
| `cleanup.sh` | Image freeze (clear logs, SSH keys, apt cache) |

### Root-space (`system/`)

Protected system configs. Owner: root.

```
system/
├── systemd/opencode.service  # Systemd unit (Restart=always, security hardening)
├── network/init.sh          # First-boot: hostname, DNS, SSH keys, UFW firewall
└── traefik/                 # System-level Traefik configs
```

### User-space (`home/devuser/`)

User-owned working files. Owner: devuser.

```
home/devuser/
├── configs/                  # Symlinks to configs/{agents,skills,mcp,plugins}
└── opencode-delivery/
    ├── docker-compose.yml   # Production compose (fixed subnet 10.200.0.0/24)
    ├── Dockerfile           # Self-contained VM image build
    └── ...
```

---

## Installation Flow

```
┌─────────────────────────────────────────────────────┐
│  STAGE 1: Prepare (один раз, машина оператора)      │
│  ./scripts/prepare.sh                               │
│  • Fork opencode-docker                             │
│  • Install olore + agents + plugins                 │
│  • Setup configs directory structure                  │
│  • Create GitHub repo                               │
└─────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────┐
│  STAGE 2: Build VM Image (Packer + QEMU)            │
│  packer/template.pkr.hcl                             │
│  • Boot Debian 12.10 netinst via QEMU/KVM           │
│  • preseed.cfg → automated install, devuser, SSH    │
│  • Provisioner: install Docker (official repo)      │
│  • Provisioner: copy system/ configs (root-space)   │
│  • Provisioner: copy home/devuser/ (user-space)     │
│  • Provisioner: pre-warm Docker images             │
│  • cleanup.sh → freeze image, clear logs            │
│                                                     │
│  OUTPUT: .qcow2 image → deploy to FirstVDS          │
└─────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────┐
│  STAGE 3: Install on VPS (один раз, клиентский VDS) │
│  ./scripts/install-vps.sh                           │
│  • Load .env (generate password if needed)          │
│  • Ensure Docker + Docker Compose installed         │
│  • Setup Traefik dirs + Basic Auth (htpasswd)       │
│  • docker-compose build/pull                        │
│  • Create volumes                                   │
│  • Configure UFW firewall (22/80/443/4096)         │
│  • docker-compose up -d                             │
└─────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────┐
│  STAGE 4: Onboard Client                            │
│  ./scripts/onboard-client.sh                         │
│  • Generate client-credentials.txt                   │
│  • Create HTML getting-started guide                │
└─────────────────────────────────────────────────────┘
```

---

## Runtime Architecture

```
┌──────────────────────────────────────────────────────┐
│                     Client VPS                        │
│                                                      │
│  ┌────────────────────────────────────────────────┐  │
│  │         Traefik v3.2 (Reverse Proxy)            │  │
│  │  Port 80   → HTTP (Let's Encrypt ACME challenge) │  │
│  │  Port 443  → HTTPS (auto SSL via Let's Encrypt) │  │
│  │  Port 31415→ Traefik Dashboard (HTTPS + Auth)   │  │
│  │  Middlewares: Basic Auth + Rate Limit (10/s)    │  │
│  └─────────────────────────┬────────────────────────┘  │
│                            │                           │
│                      ┌─────▼─────┐                   │
│                      │  OpenCode  │ Port 4096         │
│                      │   Server  │                   │
│                      └─────┬─────┘                   │
│                            │                           │
│  ┌─────────────────────────▼────────────────────────┐│
│  │              Docker Volumes (persistent)           ││
│  │  opencode_data    → sessions, auth                 ││
│  │  opencode_state   → state                         ││
│  │  opencode_config  → opencode.json, agents, skills ││
│  │  traefik_acme     → Let's Encrypt certs           ││
│  │  traefik_auth     → Basic Auth htpasswd           ││
│  │  traefik_certs    → TLS certificates              ││
│  └────────────────────────────────────────────────────┘│
│                                                      │
│  ┌────────────────────────────────────────────────┐  │
│  │         Read-only config mounts                  │  │
│  │  /home/devuser/configs/agents  → 144 agents     │  │
│  │  /home/devuser/configs/skills → skills          │  │
│  │  /home/devuser/configs/mcp    → MCP servers     │  │
│  │  /home/devuser/configs/plugins→ plugins         │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  ┌────────────────────────────────────────────────┐  │
│  │         Pre-installed MCP Servers (10)          │  │
│  │  filesystem  github  playwright  mcp-finder      │  │
│  │  mcp-discovery  mcp-compass  google-workspace  │  │
│  │  telegram  local-rag  code-sandbox              │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

---

## Network Configuration

| Port | Service | Purpose |
|------|---------|---------|
| 22/tcp | SSH | Remote management |
| 80/tcp | HTTP | Let's Encrypt HTTP-01 challenge |
| 443/tcp | HTTPS | Encrypted web access |
| 4096/tcp | OpenCode | Internal only (behind Traefik) |
| 31415/tcp | Traefik | Dashboard (HTTPS + Basic Auth) |

---

## Packer Build Parameters

| Parameter | Value |
|-----------|-------|
| **Base OS** | Debian 12.10 netinst |
| **Builder** | QEMU (.qcow2 output) |
| **Disk** | 40GB qcow2 |
| **RAM** | 4GB |
| **CPUs** | 2 |
| **Storage** | VirtIO |
| **Boot** | Legacy BIOS |
| **Provisioners** | Docker, configs copy, Docker pre-warm, cleanup |

### QEMU Builder Settings

```hcl
# packer/template.pkr.hcl
accelerator = "tcg"        # TCG-only (no KVM on server)
cpu_model = "qemu64"       # Fallback CPU model
vnc_bind_address = "0.0.0.0"
vnc_port_min = 5900
vnc_port_max = 5999
```

---

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `OPENCODE_SERVER_USERNAME` | `admin` | Basic Auth username |
| `OPENCODE_SERVER_PASSWORD` | auto-generated (14-char) | Basic Auth password |
| `TZ` | `Europe/Moscow` | Timezone |
| `AI_PROVIDER` | `antigravity` | AI provider selection |
| `DOMAIN` | `localhost` | Traefik routing host |
| `LETSENCRYPT_EMAIL` | `admin@example.com` | Let's Encrypt registration |
| `GITHUB_TOKEN` | (none) | GitHub API for fork/create repo |
| `REGISTRY_IMAGE` | (none) | Optional pre-built image registry |

---

## Docker Pre-warm

During Packer build, all critical images are pre-loaded:

```bash
docker pull ghcr.io/opencode-ai/opencode:latest
docker pull traefik:v3.2
# ... all MCP server images
```

---

## Security Configuration

### Basic Auth

htpasswd generated via `scripts/generate-password.sh`:
```bash
openssl rand -base64 18 | tr -d '/+=' | head -c 14
# Output: ~14 char password, e.g., "K9x2mPqRvN3wZ"
```

### Rate Limiting

Traefik middleware protects against brute force:
```yaml
rateLimit:
  average: 10       # requests/sec
  burst: 50        # допустимый burst
  period: 1s
```

---

## ADRs (Architecture Decision Records)

| ADR | Decision | Status |
|-----|----------|--------|
| ADR-001 | Docker-based deployment | Accepted |
| ADR-002 | Repository-first setup | Accepted |
| ADR-003 | User-selectable AI provider (antigravity/gemini/custom) | Accepted |
| ADR-004 | Full 144 agency agents pre-installed | Accepted |
| ADR-005 | All 10 MCP servers pre-installed | Accepted |
| ADR-006 | Static client documentation in container | Accepted |
| ADR-007 | Traefik v3 + Let's Encrypt + Basic Auth | Accepted |
| ADR-008 | Git-based backup strategy | Accepted |
| ADR-009 | Directory structure by division (12 divisions) | Accepted |
| ADR-010 | Standard skills structure | Accepted |
| ADR-011 | Data Layering: Build-time / Root-space / User-space | Accepted |
| ADR-012 | Cloud-init First Boot Logic | Accepted |
| ADR-013 | QEMU Builder for FirstVDS | Accepted |
| ADR-014 | Docker Pre-warm (all images) | Accepted |
| ADR-015 | Rate Limiting 10 req/sec | Accepted |
| ADR-016 | Single-User Model (MVP) | Accepted |

---

## What Pre-installed

| Component | Count | Source |
|-----------|-------|--------|
| **Agents** | 144 | agency-agents (converted to OpenCode format) |
| **MCP Servers** | 10 | filesystem, github, playwright, mcp-finder, mcp-discovery, mcp-compass, google-workspace, telegram, local-rag, code-sandbox |
| **Skills** | 4 | olore-opencode-latest, agent-memory, mcp-finder, opencode-skill-generator |
| **Plugins** | 5 | antigravity-auth, gemini-auth, subtask2, plannotator, agent-memory |
| **Documentation** | Local | olore-opencode-latest (offline-capable) |
| **Reverse Proxy** | Traefik v3.2 | Let's Encrypt + Basic Auth |
| **Security** | Rate Limiting (10 req/sec) + Brute force protection |

---

## External Dependencies

| Dependency | Purpose | Requirement |
|------------|---------|-------------|
| **Debian 12 netinst ISO** | Base OS | Downloaded from deb.debian.org during build |
| **Docker** | Container runtime | Installed via official Docker repo |
| **Let's Encrypt** | Free SSL certificates | Port 80 open, domain A-record pointing to VPS |
| **GitHub** | Repo hosting, git backup | Optional (GITHUB_TOKEN for auto-fork) |
| **agency-agents** | Source of 144 agents | Cloned during Docker build |
| **OpenCode API** | Binary download | https://opencode.ai/api/download/linux |
| **Traefik v3.2** | Reverse proxy | Downloaded from GitHub during build |
| **Node.js 20** | For olore, npm packages | Installed via NodeSource |

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `configs/opencode/opencode.json` | Master OpenCode config (MCP servers, plugins, auth, agents loading) |
| `packer/template.pkr.hcl` | Packer template for QEMU builder |
| `scripts/packer/preseed.cfg` | Debian automated installation config |
| `scripts/install-vps.sh` | VPS installation automation |
| `home/devuser/opencode-delivery/docker-compose.yml` | Production Docker Compose |
| `system/systemd/opencode.service` | Systemd unit for auto-start |
| `configs/traefik/dynamic.yml` | Traefik routing + Basic Auth + Rate Limit |

---

## WSL2 DNS Configuration

WSL2 сбрасывает DNS при каждом перезапуске. Для стабильной работы:

### 1. Отключить автогенерацию resolv.conf
```bash
# В WSL2 (один раз)
echo -e '[network]\ngenerateResolvConf = false' | sudo tee /etc/wsl.conf
echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf
```

### 2. Перезапустить WSL2
```powershell
wsl --shutdown
wsl -d Debian
```

### 3. Если resolv.conf пропал после shutdown
```powershell
wsl -d Debian -u root -- bash -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
```

---

## Next Steps

- [ ] Build Packer image (in progress — debugging QEMU/TCG timeout issues)
- [ ] Test image on FirstVDS
- [ ] Verify all MCP servers start correctly
- [ ] Test Traefik + Let's Encrypt flow
- [ ] Test client onboarding script