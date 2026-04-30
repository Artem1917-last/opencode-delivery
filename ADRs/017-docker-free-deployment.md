# ADR-017: Docker-Free Native Deployment

## Status
Proposed

## Context
Current architecture uses Docker Engine + Docker Compose with 12 containers (OpenCode, Traefik, 10 MCP servers) on a Debian 12 VM. This adds ~800MB overhead, requires Docker Engine maintenance, and complicates the Packer build pipeline. The Docker provisioners in the current Packer template are already disabled, indicating the team recognized this friction.

FirstVDS constraints:
- QCOW2 images can only be attached by admins (paid service, one-time)
- ISO upload limit: 3.5GB
- No Cloud-init, static IP only
- VirtIO drivers built into Debian 12 kernel

## Decision
Replace Docker containerization with native Debian 12 services:

1. **OpenCode**: Installed as binary during Packer build, managed by systemd
2. **Caddy v2**: Replaces Traefik as reverse proxy — single binary, automatic HTTPS, simpler config
3. **MCP servers**: Pre-installed globally via `npm install -g` and `pip3 install` during Packer build, launched as stdio subprocesses by OpenCode (no separate services needed)
4. **systemd**: Process management for OpenCode and Caddy with auto-restart and security hardening
5. **QCOW2**: Continue as delivery format — all components baked into image at build time

### Trade-off Matrix

| Concern | Docker Approach | Native Approach | Winner |
|---------|----------------|-----------------|--------|
| Image size | ~2.5GB (Debian + Docker + 12 images) | ~1.5GB (Debian + binaries) | Native |
| Startup time | 15-30s (Docker daemon + containers) | 3-5s (systemd direct start) | Native |
| RAM overhead | ~200MB (Docker daemon) | ~0MB | Native |
| Isolation | Container boundaries | None (single-tenant VPS) | Docker |
| Debugging | `docker logs`, `docker exec` | `journalctl`, direct process access | Native |
| Updates | `docker pull` + `docker compose up -d` | `apt upgrade` + `systemctl restart` | Tie |
| Complexity | Docker Engine + Compose + 12 containers | 2 systemd units + 2 binaries | Native |
| HTTPS setup | Traefik + ACME config | Caddy automatic (zero config) | Native |

## Consequences

### Easier
- ~40% smaller VM image (no Docker layers, no 12 container images)
- Faster boot: systemd starts 2 services directly vs Docker daemon + 12 containers
- Simpler debugging: `journalctl -u opencode` instead of `docker logs`
- Caddy auto-HTTPS with zero ACME configuration
- No Docker Engine security surface area

### Harder
- No container isolation — OpenCode runs as `devuser` directly on host (acceptable for single-tenant VPS)
- MCP server dependency conflicts possible (all share same Node.js/Python environment)
- No easy rollback to previous version (would need snapshot or re-provision)

### Mitigations
- OpenCode runs as unprivileged `devuser` (not root)
- systemd sandboxing (`ProtectSystem`, `NoNewPrivileges`, etc.) provides process-level isolation
- QCOW2 snapshot before updates enables rollback
- Packer build is reproducible — can rebuild image from scratch

### Reversibility
If container isolation becomes necessary:
- Docker can be installed alongside native services
- OpenCode binary can be wrapped in a container later
- Caddy config is portable to Traefik if needed
