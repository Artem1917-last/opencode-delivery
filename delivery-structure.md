# OpenCode Delivery — Technical Documentation

## Concept

Ready-to-use solution for micro-business automation. Client receives a QCOW2 VM image with OpenCode pre-installed — boots, runs, works. No Docker, no terminal skills required.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  Delivery Flow                      │
├─────────────────────────────────────────────────────┤
│ STAGE 1: Prepare (one-time, operator machine)       │
│   Fork repo, install agents, configs                │
├─────────────────────────────────────────────────────┤
│ STAGE 2: Build VM Image (Packer + QEMU)             │
│   template.pkr.hcl → .qcow2 image for FirstVDS      │
│   Native install: Node.js + OpenCode + Caddy + MCP  │
├─────────────────────────────────────────────────────┤
│ STAGE 3: Deploy on VPS (one-time)                   │
│   Upload QCOW2 → FirstVDS admin attaches → boot     │
├─────────────────────────────────────────────────────┤
│ STAGE 4: Onboard Client                              │
│   Generate credentials + docs                        │
└─────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
opencode-delivery/
├── ADRs/                              # Architecture Decision Records
│   ├── 001-architecture-decisions.md  # Original 10 key decisions
│   └── 017-docker-free-deployment.md  # Docker → Native migration
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
│   │   └── opencode.json            # JSON schema config (MCP as local commands)
│   ├── plugins/                     # Plugin configs
│   └── env.example                  # Environment template
├── documentation/                    # Client-facing docs (built at onboard)
├── home/                             # User-space files (embedded in VM)
│   └── devuser/
│       ├── configs/                  # Symlinks to configs/
│       └── .opencode/
│           └── opencode.json         # User-level OpenCode config
├── packer/                          # Packer VM builder
│   └── template.pkr.hcl             # QEMU builder for Debian 12 (native install)
├── scripts/                         # Installation scripts
│   ├── prepare.sh                   # Stage 1: fork repo, install agents
│   ├── onboard-client.sh            # Stage 3: generate credentials
│   ├── generate-password.sh         # 14-char password generator
│   └── packer/                     # Packer build-time scripts
│       ├── preseed.cfg             # Debian 12 automated install
│       └── cleanup.sh             # Image freeze (logs, cache, SSH keys)
├── system/                          # Root-space configs (embedded in VM)
│   ├── systemd/
│   │   ├── opencode-web.service    # Systemd unit for OpenCode web server
│   │   └── caddy.service           # Systemd unit for Caddy reverse proxy
│   ├── network/
│   │   └── init.sh                 # First-boot network/SSH/firewall
│   └── caddy/
│       └── Caddyfile               # Reverse proxy + HTTPS + Basic Auth
├── Dockerfile                       # Legacy Docker image (deprecated)
└── README.md                        # Main documentation (Russian)
```

---

## Data Layering

### Build-time only (`scripts/packer/`)

Files needed only for Packer image creation. Deleted after assembly.

| File | Purpose |
|------|---------|
| `preseed.cfg` | Debian automated install answers |
| `cleanup.sh` | Image freeze (clear logs, SSH keys, apt cache, npm cache) |

### Root-space (`system/`)

Protected system configs. Owner: root.

```
system/
├── systemd/
│   ├── opencode-web.service  # Systemd unit (user=devuser, security hardening)
│   └── caddy.service         # Systemd unit for Caddy reverse proxy
├── network/init.sh          # First-boot: hostname, DNS, SSH keys, UFW firewall
└── caddy/
    └── Caddyfile            # Reverse proxy config (HTTPS + Basic Auth)
```

### User-space (`home/devuser/`)

User-owned working files. Owner: devuser.

```
home/devuser/
├── configs/                  # Symlinks to configs/{agents,skills,mcp,plugins}
└── .opencode/
    └── opencode.json         # User-level OpenCode config (MCP as stdio commands)
```

---

## Installation Flow

```
┌─────────────────────────────────────────────────────┐
│  STAGE 1: Prepare (один раз, машина оператора)      │
│  • Fork opencode-delivery                           │
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
│  • Provisioner: install Node.js 22 (NodeSource)     │
│  • Provisioner: install OpenCode binary (curl)       │
│  • Provisioner: install Caddy binary (apt)           │
│  • Provisioner: install MCP servers (npm -g)         │
│  • Provisioner: copy system/ configs (root-space)   │
│  • Provisioner: copy home/devuser/ (user-space)     │
│  • cleanup.sh → freeze image, clear logs            │
│                                                     │
│  OUTPUT: .qcow2 image → deploy to FirstVDS          │
└─────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────┐
│  STAGE 3: Deploy on VPS (один раз, клиентский VDS)  │
│  • Upload QCOW2 to FirstVDS                         │
│  • Admin attaches QCOW2 to VPS                      │
│  • Boot → systemd starts OpenCode + Caddy           │
│  • Configure static IP (client-side)                │
│  • Caddy auto-provisions Let's Encrypt SSL          │
└─────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────┐
│  STAGE 4: Onboard Client                            │
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
│  │         Caddy v2 (Reverse Proxy)                │  │
│  │  Port 80   → HTTP (Let's Encrypt HTTP-01)       │  │
│  │  Port 443  → HTTPS (auto SSL)                   │  │
│  │  Middlewares: Basic Auth                        │  │
│  └─────────────────────────┬────────────────────────┘  │
│                            │                           │
│                      ┌─────▼─────┐                   │
│                      │  OpenCode  │ Port 4096         │
│                      │   Server  │ (127.0.0.1)       │
│                      └─────┬─────┘                   │
│                            │                           │
│  ┌─────────────────────────▼────────────────────────┐│
│  │              Persistent Data                       ││
│  │  /home/devuser/.opencode/  → sessions, config     ││
│  │  /home/devuser/configs/    → agents, skills, MCP  ││
│  │  /etc/caddy/Caddyfile      → reverse proxy config ││
│  └────────────────────────────────────────────────────┘│
│                                                      │
│  ┌────────────────────────────────────────────────┐  │
│  │         Pre-installed MCP Servers (10)          │  │
│  │  Launched as stdio subprocesses by OpenCode     │  │
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
| 4096/tcp | OpenCode | Internal only (behind Caddy) |

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
| **Provisioners** | Node.js 22, OpenCode binary, Caddy, MCP npm, configs copy, cleanup |

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
| `DOMAIN` | `localhost` | Caddy routing host |
| `LETSENCRYPT_EMAIL` | `admin@example.com` | Let's Encrypt registration |
| `GITHUB_TOKEN` | (none) | GitHub API for fork/create repo |

---

## Security Configuration

### Basic Auth

htpasswd generated via `scripts/generate-password.sh`:
```bash
openssl rand -base64 18 | tr -d '/+=' | head -c 14
# Output: ~14 char password, e.g., "K9x2mPqRvN3wZ"
```

### systemd Sandboxing

Both services run with security hardening:
```ini
ProtectSystem=strict
NoNewPrivileges=yes
PrivateTmp=yes
ProtectHome=yes
```

---

## ADRs (Architecture Decision Records)

| ADR | Decision | Status |
|-----|----------|--------|
| ADR-001 | Docker-based deployment | **Superseded** by ADR-017 |
| ADR-002 | Repository-first setup | Accepted |
| ADR-003 | User-selectable AI provider (antigravity/gemini/custom) | Accepted |
| ADR-004 | Full 144 agency agents pre-installed | Accepted |
| ADR-005 | All 10 MCP servers pre-installed | Accepted |
| ADR-006 | Static client documentation in container | **Superseded** |
| ADR-007 | Traefik v3 + Let's Encrypt + Basic Auth | **Superseded** by ADR-017 |
| ADR-008 | Git-based backup strategy | Accepted |
| ADR-009 | Directory structure by division (12 divisions) | Accepted |
| ADR-010 | Standard skills structure | Accepted |
| ADR-011 | Data Layering: Build-time / Root-space / User-space | Accepted |
| ADR-012 | Cloud-init First Boot Logic | Accepted |
| ADR-013 | QEMU Builder for FirstVDS | Accepted |
| ADR-014 | Docker Pre-warm (all images) | **Superseded** |
| ADR-015 | Rate Limiting 10 req/sec | Accepted |
| ADR-016 | Single-User Model (MVP) | Accepted |
| ADR-017 | **Docker-Free Native Deployment** | **Accepted** |

---

## What Pre-installed

| Component | Count | Source |
|-----------|-------|--------|
| **Agents** | 144 | agency-agents (converted to OpenCode format) |
| **MCP Servers** | 10 | Global npm/pip packages (stdio subprocesses) |
| **Skills** | 4 | olore-opencode-latest, agent-memory, mcp-finder, opencode-skill-generator |
| **Plugins** | 5 | antigravity-auth, gemini-auth, subtask2, plannotator, agent-memory |
| **Documentation** | Local | olore-opencode-latest (offline-capable) |
| **Reverse Proxy** | Caddy v2 | Let's Encrypt + Basic Auth |
| **Security** | systemd sandboxing + UFW firewall |

---

## External Dependencies

| Dependency | Purpose | Requirement |
|------------|---------|-------------|
| **Debian 12 netinst ISO** | Base OS | Downloaded from deb.debian.org during build |
| **Node.js 22** | Runtime for OpenCode + MCP servers | NodeSource repo |
| **Let's Encrypt** | Free SSL certificates | Port 80 open, domain A-record pointing to VPS |
| **GitHub** | Repo hosting, git backup | Optional (GITHUB_TOKEN for auto-fork) |
| **agency-agents** | Source of 144 agents | Cloned during Packer build |
| **OpenCode API** | Binary download | https://opencode.ai/api/download/linux |
| **Caddy v2** | Reverse proxy | Installed via apt (caddyserver repo) |

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `configs/opencode/opencode.json` | Master OpenCode config (MCP servers as local commands) |
| `packer/template.pkr.hcl` | Packer template for QEMU builder (native install) |
| `scripts/packer/preseed.cfg` | Debian automated installation config |
| `system/systemd/opencode-web.service` | Systemd unit for OpenCode web server |
| `system/systemd/caddy.service` | Systemd unit for Caddy reverse proxy |
| `system/caddy/Caddyfile` | Caddy reverse proxy + HTTPS + Basic Auth |
| `home/devuser/.opencode/opencode.json` | User-level OpenCode config |

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

- [x] Build Packer image with native services
- [ ] Test image on FirstVDS
- [ ] Verify all MCP servers start correctly as stdio subprocesses
- [ ] Test Caddy + Let's Encrypt flow
- [ ] Test client onboarding script
