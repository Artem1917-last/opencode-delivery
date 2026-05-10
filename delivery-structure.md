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
│   Direct kernel boot, preseed late_command only     │
│   Native install: Node.js + OpenCode + Caddy        │
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
│   ├── 001-architecture-decisions.md  # ADRs 001-010 bundled together
│   └── 017-docker-free-deployment.md  # Docker → Native migration
├── documentation/                     # Client-facing docs (built at onboard)
├── packer/                           # Packer VM builder
│   ├── template.pkr.hcl             # QEMU builder for Debian 12 (direct kernel boot)
│   └── files/                       # Binary tarballs + kernel/initrd
│       ├── debian-12.10.0-amd64-netinst.iso
│       ├── node-v22.14.0-linux-x64.tar.xz
│       ├── opencode-linux-x64.tar.gz
│       ├── caddy_2.11.2_linux_amd64.tar.gz
│       ├── vmlinuz                    # Direct kernel boot
│       └── initrd.gz                  # Direct kernel initrd
├── scripts/                         # Installation scripts
│   ├── packer/
│   │   ├── preseed.cfg              # Debian 12 automated install + late_command
│   │   ├── cleanup.sh               # Image freeze (logs, cache, SSH keys)
│   │   └── package-repo.bat         # Creates repo.tar.gz from repo/ directory
│   ├── prepare.sh                   # Stage 1: fork repo, install agents
│   ├── onboard-client.sh            # Stage 3: generate credentials
│   └── generate-password.sh         # 14-char password generator
├── repo/                            # Filesystem mirror → packed into repo.tar.gz
│   ├── etc/                         # Root system configs (target: /etc)
│   │   ├── caddy/
│   │   │   └── Caddyfile           # Reverse proxy + HTTPS + Basic Auth
│   │   ├── systemd/system/
│   │   │   ├── opencode-web.service # Systemd unit for OpenCode native binary
│   │   │   ├── caddy.service        # Systemd unit for Caddy reverse proxy
│   │   │   └── opencode.service     # Legacy Docker-based unit (kept for reference)
│   │   └── traefik/                # Legacy Traefik configs (kept for reference)
│   │       ├── acme/acme.json
│   │       ├── auth/htpasswd
│   │       ├── certs/placeholder.pem
│   │       ├── certs/placeholder.key
│   │       ├── dynamic.yml
│   │       └── tls.yml
│   ├── home/devuser/               # User-space files (target: /home/devuser)
│   │   ├── .opencode/
│   │   │   └── opencode.json       # User-level OpenCode config (127.0.0.1 bind)
│   │   ├── configs/                # Empty mount points for agents/skills/mcp/plugins
│   │   │   ├── agents/
│   │   │   ├── skills/
│   │   │   ├── mcp/
│   │   │   └── plugins/
│   │   └── opencode-delivery/      # Legacy Docker files (kept for reference)
│   │       ├── docker-compose.yml
│   │       ├── Dockerfile
│   │       └── README.md
│   ├── opt/opencode/               # Empty — binary installed at /usr/local/bin
│   ├── root/.config/opencode/      # Root-level config (target: /root/.config/opencode)
│   │   ├── opencode.json           # Root-level OpenCode config (0.0.0.0 bind)
│   │   ├── agents/                 # 12 division dirs, 4 agent .md files
│   │   │   ├── engineering/
│   │   │   ├── design/
│   │   │   ├── marketing/
│   │   │   ├── sales/
│   │   │   ├── specialized/
│   │   │   ├── project-management/
│   │   │   ├── testing/
│   │   │   ├── support/
│   │   │   ├── paid-media/
│   │   │   ├── product/
│   │   │   ├── finance/
│   │   │   └── game-development/
│   │   ├── skills/                 # 4 OpenCode skills
│   │   │   ├── agent-memory/
│   │   │   ├── mcp-finder/
│   │   │   ├── olore-opencode-latest/
│   │   │   └── opencode-skill-generator/
│   │   ├── mcp/                    # Empty (config is inline in opencode.json)
│   │   └── plugins/                # Empty (config is inline in opencode.json)
│   └── usr/local/bin/
│       └── init.sh                # First-boot network/SSH/firewall script
├── .gitignore
└── README.md                       # Main documentation (Russian)
```

> **Note**: `repo/` is a complete filesystem mirror of everything that gets installed into the VM. It is archived into `repo.tar.gz` by `scripts/packer/package-repo.bat` before each Packer build, served via Packer's HTTP server, and extracted in `late_command` with a single `wget | tar xzf -` pipeline.

---

## Data Layering

### Build-time only (`scripts/packer/` + `packer/files/`)

Files needed only for Packer image creation. Not included in final VM image.

| File | Purpose |
|------|---------|
| `packer/template.pkr.hcl` | Packer template (QEMU builder, direct kernel boot) |
| `packer/files/debian-12.10.0-amd64-netinst.iso` | Debian install ISO |
| `packer/files/vmlinuz` | Linux kernel for direct boot |
| `packer/files/initrd.gz` | Initrd for direct boot |
| `packer/files/node-v22.14.0-linux-x64.tar.xz` | Node.js binary tarball |
| `packer/files/opencode-linux-x64.tar.gz` | OpenCode binary tarball |
| `packer/files/caddy_2.11.2_linux_amd64.tar.gz` | Caddy binary tarball |
| `scripts/packer/preseed.cfg` | Debian automated install + late_command (all provisioning) |
| `scripts/packer/cleanup.sh` | Image freeze (clear logs, SSH keys, apt cache, npm cache) |
| `scripts/packer/package-repo.bat` | Creates `repo.tar.gz` from `repo/` directory |

### Repo archive (`repo/` → `repo.tar.gz`)

The entire `repo/` tree is archived into `repo.tar.gz` and extracted into the VM root at install time. This is the single artifact that delivers all configuration files.

#### Root-space (`repo/etc/`)

Protected system configs. Owner: root.

| Path | Purpose |
|------|---------|
| `etc/caddy/Caddyfile` | Caddy reverse proxy config (HTTPS + Basic Auth) |
| `etc/systemd/system/opencode-web.service` | Systemd unit (user=devuser, security hardening) |
| `etc/systemd/system/caddy.service` | Systemd unit for Caddy reverse proxy |
| `usr/local/bin/init.sh` | First-boot: hostname, DNS, SSH keys, UFW firewall |

#### User-space (`repo/home/devuser/`)

User-owned working files. Owner: devuser.

| Path | Purpose |
|------|---------|
| `home/devuser/.opencode/opencode.json` | User-level OpenCode config (MCP as npx commands, auth providers) |
| `home/devuser/configs/agents/` | Empty mount point for agents (populated at build or runtime) |
| `home/devuser/configs/skills/` | Empty mount point for skills |
| `home/devuser/configs/mcp/` | Empty mount point for MCP |
| `home/devuser/configs/plugins/` | Empty mount point for plugins |

#### Reference configs (`repo/root/.config/opencode/`)

Root-level OpenCode config with seed agents, skills, and server bindings.

| Path | Purpose |
|------|---------|
| `root/.config/opencode/opencode.json` | Root-level config (binds 0.0.0.0:4096, MCP as npx commands) |
| `root/.config/opencode/agents/` | 12 division dirs with 4 seed agent .md files |
| `root/.config/opencode/skills/` | 4 pre-installed OpenCode skills (SKILL.md each) |

---

## Installation Flow

```
┌─────────────────────────────────────────────────────┐
│  STAGE 1: Prepare (один раз, машина оператора)       │
│  • Fork opencode-delivery                            │
│  • Install olore + agents + plugins                  │
│  • Setup repo/ directory structure                   │
│  • Create GitHub repo                                │
└─────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────┐
│  STAGE 2: Build VM Image (Packer + QEMU)             │
│                                                      │
│  Pre-build (operator machine):                       │
│  • scripts/packer/package-repo.bat                   │
│    → creates repo.tar.gz from repo/                  │
│                                                      │
│  Packer build (QEMU + WHPX):                         │
│  • Direct kernel boot (-kernel/-initrd/-append)      │
│  • preseed.cfg → automated Debian 12 install         │
│  • Network: DHCP (QEMU user-mode)                    │
│  • late_command (ALL provisioning):                  │
│    1. apt install base packages                      │
│    2. wget Node.js → extract to /usr/local           │
│    3. wget OpenCode binary → /usr/local/bin          │
│    4. wget Caddy binary → /usr/local/bin             │
│    5. wget repo.tar.gz → tar xzf - to /target        │
│    6. Enable services (sshd, opencode-web, caddy)    │
│    7. Set hostname, SSH config, sudoers              │
│  • QEMU exits on install finish (-no-reboot)         │
│                                                      │
│  OUTPUT: output-debian12/opencode-debian12.qcow2     │
└─────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────┐
│  STAGE 3: Deploy on VPS (один раз, клиентский VDS)   │
│  • Upload QCOW2 to FirstVDS                          │
│  • Admin attaches QCOW2 to VPS                       │
│  • Boot → systemd starts OpenCode + Caddy            │
│  • init.sh configures network on first boot          │
│  • Caddy auto-provisions Let's Encrypt SSL           │
└─────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────┐
│  STAGE 4: Onboard Client                             │
│  • Generate client-credentials.txt                   │
│  • Create HTML getting-started guide                 │
└─────────────────────────────────────────────────────┘
```

### Provisioning Detail (late_command pipeline)

All provisioning happens in a single `preseed/late_command` string — there are **no Packer provisioners** (`communicator = "none"`):

1. **System packages**: `unzip jq htop net-tools dnsutils nano gnupg systemd systemd-sysv`
2. **Node.js 22.14**: Binary tarball from Packer HTTP → `/usr/local`
3. **OpenCode binary**: Tarball → `/usr/local/bin/opencode`
4. **Caddy 2.11.2**: Binary tarball → `/usr/local/bin/caddy`, create `caddy` user/group
5. **Repo archive**: `wget -qO- http://10.0.2.2:8563/repo.tar.gz | tar xzf - -C /target` — extracts all configs
6. **Service enablement**: `sshd`, `opencode-web.service`, `caddy.service`
7. **System config**: hostname, `/etc/hosts`, sudoers, SSH password auth

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
│  │         MCP Servers (defined in config)         │  │
│  │  Launched as stdio subprocesses by OpenCode     │  │
│  │  (lazy-installed via npx on first use)          │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

**Key runtime decisions:**
- **No Docker** — OpenCode runs as a native binary via systemd
- **No Traefik** — Caddy v2 handles reverse proxy + automatic HTTPS
- **Caddy on ports 80/443**, proxying to **OpenCode on 127.0.0.1:4096**
- **OpenCode binds to 127.0.0.1** (not exposed directly) — Caddy is the only entry point
- **MCP servers** defined as `npx` commands in `opencode.json` — installed on first use (lazy)

---

## Network Configuration

| Port | Service | Purpose |
|------|---------|---------|
| 22/tcp | SSH | Remote management |
| 80/tcp | HTTP | Let's Encrypt HTTP-01 challenge |
| 443/tcp | HTTPS | Encrypted web access |
| 4096/tcp | OpenCode | Internal only (127.0.0.1, behind Caddy) |

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
| **Boot** | Direct kernel boot (`-kernel` + `-initrd` + `-append`) |
| **Accelerator** | `whpx` (Windows Hypervisor Platform) |
| **Communicator** | `none` (all provisioning in preseed late_command) |
| **Machine type** | `pc` (legacy BIOS) |
| **HTTP port** | 8563 (fixed) |
| **VNC port** | 5910 (fixed) |
| **Disk compaction** | `skip_compaction = true` (fix for qemu-img.exe crash on Windows) |
| **Provisioners** | None — everything in late_command: Node.js, OpenCode, Caddy, repo.tar.gz |

### QEMU Builder Settings

```hcl
# packer/template.pkr.hcl (source "qemu" "debian12")
accelerator = "whpx"         # WHPX on Windows (not TCG)
cpu_model   = "qemu64"       # Fallback CPU model
machine_type = "pc"          # Legacy BIOS (not UEFI)
communicator = "none"        # No SSH provisioners
skip_compaction = true       # Avoid qemu-img.exe crash

vnc_bind_address = "0.0.0.0"
vnc_port_min     = 5910
vnc_port_max     = 5910

http_directory = "${path.root}/../"   # Serves from project root
http_port_min  = 8563
http_port_max  = 8563

qemuargs = [
  ["-kernel",  "packer/files/vmlinuz"],
  ["-initrd",  "packer/files/initrd.gz"],
  ["-append",  "auto=true priority=critical url=http://10.0.2.2:8563/scripts/packer/preseed.cfg console=ttyS0,115200 net.ifnames=0"],
  ["-no-reboot"],
  ["-boot",    "order=dc"],
  ["-serial",  "file:C:/opencode-delivery/serial.log"]
]
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
[Service]
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
```

`caddy.service` additionally:
```ini
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
AmbientCapabilities=CAP_NET_BIND_SERVICE
```

---

## ADRs (Architecture Decision Records)

| ADR | Decision | Status |
|-----|----------|--------|
| ADR-001 | Docker-based deployment (original) | Accepted |
| ADR-002 | Repository-first setup | Accepted |
| ADR-003 | User-selectable AI provider (antigravity/gemini/custom) | Accepted |
| ADR-004 | Full agency agents pre-installed | Accepted |
| ADR-005 | All MCP servers pre-installed | Accepted |
| ADR-006 | Static client documentation in container | Accepted |
| ADR-007 | Nginx Proxy Manager + Basic Auth | Accepted |
| ADR-008 | Git-based backup strategy | Accepted |
| ADR-009 | Directory structure by division (12 divisions) | Accepted |
| ADR-010 | Standard skills structure | Accepted |
| ADR-017 | **Docker-Free Native Deployment** (Caddy, systemd, no Docker) | **Proposed** |

> **Note**: All 10 ADRs (001-010) are bundled in a single file `ADRs/001-architecture-decisions.md`. ADR-017 is a separate file. ADRs 011-016 exist only as references in the old documentation and were never written as standalone files. ADRs 006 and 007 are superseded by ADR-017 in practice but not formally marked.

---

## What Pre-installed

| Component | Count | Source / Location |
|-----------|-------|-------------------|
| **Agents** | 4 seed agents (12 division dirs) | `repo/root/.config/opencode/agents/` — engineering (2), project-management (1), specialized (1) |
| **MCP Server configs** | 10 | Defined as `npx` commands in `opencode.json` (lazy-installed on first use) |
| **Skills** | 4 | `repo/root/.config/opencode/skills/` — agent-memory, mcp-finder, olore-opencode-latest, opencode-skill-generator |
| **Plugins** | 5 | Listed in `opencode.json`: @opencode/agent-memory, @plannotator/opencode, @openspoon/subtask2, @opencode/antigravity-auth, @opencode/gemini-auth |
| **Runtime** | Node.js 22.14 | Binary in `/usr/local/bin` |
| **OpenCode** | Latest | Binary in `/usr/local/bin/opencode` |
| **Reverse Proxy** | Caddy v2.11.2 | Binary in `/usr/local/bin/caddy`, managed by systemd |
| **Security** | systemd sandboxing + UFW firewall | Configured via init.sh + service unit hardening |

---

## External Dependencies

| Dependency | Purpose | Requirement |
|------------|---------|-------------|
| **Debian 12 netinst ISO** | Base OS | Downloaded from deb.debian.org during build |
| **Node.js 22** | Runtime for OpenCode + MCP servers | Binary tarball served via Packer HTTP |
| **Let's Encrypt** | Free SSL certificates | Port 80 open, domain A-record pointing to VPS |
| **GitHub** | Repo hosting, git backup | Optional (GITHUB_TOKEN for auto-fork) |
| **OpenCode API** | Binary download | Tarball served via Packer HTTP |
| **Caddy v2** | Reverse proxy | Binary tarball served via Packer HTTP |

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `packer/template.pkr.hcl` | Packer template for QEMU builder (direct kernel boot, native install) |
| `packer/files/vmlinuz` | Linux kernel for direct boot |
| `packer/files/initrd.gz` | Initrd for direct boot |
| `scripts/packer/preseed.cfg` | Debian automated installation + late_command provisioning |
| `scripts/packer/cleanup.sh` | Image freeze (logs, cache, SSH keys, zero free space) |
| `scripts/packer/package-repo.bat` | Creates `repo.tar.gz` from `repo/` directory |
| `repo/etc/caddy/Caddyfile` | Caddy reverse proxy + HTTPS + Basic Auth |
| `repo/etc/systemd/system/opencode-web.service` | Systemd unit for OpenCode web server (native binary) |
| `repo/etc/systemd/system/caddy.service` | Systemd unit for Caddy reverse proxy |
| `repo/usr/local/bin/init.sh` | First-boot network/SSH/firewall configuration |
| `repo/home/devuser/.opencode/opencode.json` | User-level OpenCode config (binds 127.0.0.1) |
| `repo/root/.config/opencode/opencode.json` | Root-level OpenCode config (binds 0.0.0.0) |
| `repo/root/.config/opencode/agents/` | 12 division directories with seed agent files |

---

## Build Workflow (Windows Operator)

### Prerequisites
- QEMU installed at `C:\Program Files\qemu\`
- Packer (`packer.exe`) in project root
- WHPX enabled (Windows Hypervisor Platform)
- VNC viewer (TightVNC) for debugging

### Build Steps

```cmd
:: 1. Package repo/ → repo.tar.gz
scripts\packer\package-repo.bat

:: 2. Init and validate
packer.exe init packer/template.pkr.hcl
packer.exe validate packer/template.pkr.hcl

:: 3. Build
packer.exe build packer/template.pkr.hcl

:: 4. Debug build (if needed)
set PACKER_LOG=1
set PACKER_LOG_FILE=packer-debug.log
packer.exe build -on-error=ask packer/template.pkr.hcl
```

### Log files after build

| File | Content |
|------|---------|
| Console output | Provisioner progress, errors |
| `serial.log` | Full VM boot serial console output |
| `packer-debug.log` | Packer internal debug (when PACKER_LOG=1) |
| `manifest.json` | Build artifact manifest |

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
- [x] Direct kernel boot working (no ISOLINUX/gfxboot issues)
- [x] Windows WHPX accelerator confirmed working
- [x] skip_compaction fix for qemu-img.exe crash
- [ ] Test image on FirstVDS
- [ ] Verify all MCP servers start correctly as stdio subprocesses
- [ ] Test Caddy + Let's Encrypt flow
- [ ] Populate full 144-agent set from agency-agents
- [ ] Test client onboarding script
