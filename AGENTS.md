# OpenCode Delivery

Infrastructure project for deploying OpenCode on VPS via Docker + Packer + Traefik.

## Environment

- **OS**: Windows 10
- **Shell**: cmd.exe (use cmd syntax: `dir`, `del`, `copy`, `&&`, `|`)
- **Node.js**: v24.x, npm 11.x
- **Packer**: `packer.exe` in project root
- **Docker**: not installed locally — scripts target remote VPS
- **Git**: not installed
- **Target platform**: Linux (Debian 12 / Ubuntu 24.04)

## Shell Rules

- Use **cmd syntax** for all terminal commands
- Do NOT use bash syntax (`ls`, `rm`, `cp`, `cat`, `grep`) — use cmd equivalents (`dir`, `del`, `copy`, `type`, `findstr`)
- Bash scripts in `scripts/` are for Linux VPS, do NOT run them locally
- Use `cmd /c "command"` when running through tools

## Project Structure

```
configs/         — Central configs (agents, skills, mcp, traefik, opencode.json)
scripts/         — Installation scripts (.sh for Linux VPS)
packer/          — Packer VM builder (template.pkr.hcl)
system/          — Root-space configs (systemd, network, traefik)
home/            — User-space files (docker-compose, Dockerfile)
ADRs/            — Architecture Decision Records
documentation/   — Client-facing docs
```

## Monitoring & Debugging Packer Build

```cmd
:: Standard build
.\packer.exe build packer\template.pkr.hcl

:: Detailed debug log (writes to packer-debug.log)
set PACKER_LOG=1
set PACKER_LOG_FILE=packer-debug.log
.\packer.exe build packer\template.pkr.hcl

:: Pause on error (gives SSH access to failed VM)
.\packer.exe build -on-error=ask packer\template.pkr.hcl

:: Step-by-step debug mode
.\packer.exe build -debug packer\template.pkr.hcl
```

### Log files after build

| File | Content |
|------|---------|
| Console output | Provisioner progress, errors |
| `serial.log` | Full VM boot output |
| `packer-debug.log` | Packer internal debug (when PACKER_LOG=1) |

## Key Commands

```
packer.exe init packer/template.pkr.hcl     — Init Packer template
packer.exe validate packer/template.pkr.hcl — Validate template
packer.exe build packer/template.pkr.hcl    — Build VM image
node --version                               — Check Node.js
npm install -g <package>                     — Install global npm package
```

## Important

- `.sh` scripts in `scripts/` run on Linux VPS only, not on Windows
- Docker Compose files in `home/devuser/opencode-delivery/` are for the target VPS
- The Dockerfile builds an Ubuntu 24.04 container with OpenCode pre-installed
- Traefik v3 handles reverse proxy + Let's Encrypt SSL on the VPS
