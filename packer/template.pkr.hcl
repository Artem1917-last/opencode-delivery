# =============================================================================
# OpenCode Delivery - Packer Template for FirstVDS (QEMU/KVM)
# =============================================================================
# Target: Debian 12.10.0 netinst on FirstVDS KVM
# Boot: Legacy BIOS
# Output: .qcow2 image (converted to ISO for FirstVDS delivery)
# Architecture: Native services (no Docker)
#   - OpenCode web server (binary)
#   - Caddy reverse proxy (binary)
#   - MCP servers (npm global packages)
#   - Node.js 22 runtime
# Build-time network: DHCP (QEMU default) - works automatically
# Runtime network: Static IP - client configures at FirstVDS deployment
# =============================================================================

packer {
  required_version = ">= 1.10.0"
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

# =============================================================================
# Variables
# =============================================================================

variable "iso_url" {
  type        = string
  default     = "https://cdimage.debian.org/cdimage/archive/12.10.0/amd64/iso-cd/debian-12.10.0-amd64-netinst.iso"
  description = "Debian 12.10.0 netinst.iso - full installer with base system included"
}

variable "iso_checksum" {
  type        = string
  default     = "sha256:ee8d8579128977d7dc39d48f43aec5ab06b7f09e1f40a9d98f2a9d149221704a"
  description = "Debian 12.10.0 netinst.iso checksum (sha256)"
}

variable "ssh_username" {
  type        = string
  default     = "devuser"
  description = "SSH username for communicator"
}

variable "ssh_password" {
  type      = string
  default   = "packer"
  sensitive = true
  description = "SSH password (temporary - client must change after deployment)"
}

variable "disk_size" {
  type        = number
  default     = 40960
  description = "Disk size in MB"
}

variable "memory" {
  type        = number
  default     = 4096
  description = "RAM in MB"
}

variable "cpus" {
  type        = number
  default     = 2
  description = "Number of CPUs"
}

variable "headless" {
  type        = bool
  default     = true
  description = "Run in headless mode (no GUI)"
}

# =============================================================================
# Source: QEMU Builder for Debian 12 (Legacy BIOS)
# =============================================================================

source "qemu" "debian12" {
  boot_wait    = "5s"
  boot_command = [
    "<tab><wait>",
    "auto=true priority=critical url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg net.ifnames=0",
    "<enter>"
  ]

  http_directory = "${path.root}/../scripts/packer"

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  machine_type = "pc"

  disk_size         = var.disk_size
  output_directory   = "output-debian12"
  disk_image        = false
  format            = "qcow2"

  memory            = var.memory
  cpus              = var.cpus
  net_device        = "virtio-net-pci"
  disk_interface    = "virtio"

  display           = "none"
  headless          = var.headless

  vnc_bind_address  = "0.0.0.0"
  vnc_port_min      = 5910
  vnc_port_max      = 5919

  communicator      = "ssh"
  ssh_port          = 22
  ssh_timeout       = "30m"
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  ssh_handshake_attempts = 100
  ssh_disable_agent_forwarding = true

  qemu_binary       = "C:/Program Files/qemu/qemu-system-x86_64.exe"
  accelerator       = "whpx"
  cpu_model         = "qemu64"

  vm_name           = "opencode-debian12.qcow2"
}

# =============================================================================
# Build Section
# =============================================================================

build {
  name = "opencode-delivery"

  sources = ["source.qemu.debian12"]

  # ---------------------------------------------------------------------
  # Provisioner 1: Wait for system to settle
  # ---------------------------------------------------------------------
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "echo 'Waiting for system to settle after installation...'",
      "sleep 30",
      "echo 'System ready for provisioning'"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner 2: Install base packages + Node.js 22
  # ---------------------------------------------------------------------
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "apt-get update",
      "apt-get install -y curl wget git unzip jq htop net-tools dnsutils vim nano sudo systemd systemd-sysv ca-certificates gnupg",
      "curl -fsSL https://deb.nodesource.com/setup_22.x | bash -",
      "apt-get install -y nodejs",
      "node --version",
      "npm --version",
      "echo 'Base packages + Node.js 22 installed'"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner 3: Install OpenCode binary
  # ---------------------------------------------------------------------
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "curl -fsSL https://opencode.ai/api/download/linux -o /tmp/opencode",
      "chmod +x /tmp/opencode",
      "mv /tmp/opencode /usr/local/bin/opencode",
      "opencode --version || echo 'OpenCode binary installed'",
      "echo 'OpenCode installed'"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner 4: Install Caddy binary + create caddy user
  # ---------------------------------------------------------------------
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "curl -fsSL https://caddyserver.com/api/download?os=linux&arch=amd64 -o /tmp/caddy.tar.gz",
      "tar -xzf /tmp/caddy.tar.gz -C /tmp",
      "mv /tmp/caddy /usr/local/bin/caddy",
      "chmod +x /usr/local/bin/caddy",
      "rm /tmp/caddy.tar.gz",
      "caddy version",
      "groupadd --system caddy 2>/dev/null || true",
      "useradd --system --gid caddy --no-create-home --home-dir /var/lib/caddy --shell /usr/sbin/nologin caddy",
      "mkdir -p /etc/caddy /var/lib/caddy /var/log/caddy",
      "chown -R caddy:caddy /var/lib/caddy /var/log/caddy",
      "echo 'Caddy installed'"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner 5: Install MCP servers globally via npm
  # DISABLED FOR TEST BUILD - MCP servers will be added later
  # ---------------------------------------------------------------------
  # provisioner "shell" {
  #   execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
  #   inline = [
  #     "npm install -g @modelcontextprotocol/server-filesystem",
  #     "npm install -g @modelcontextprotocol/server-github",
  #     "npm install -g @modelcontextprotocol/server-playwright",
  #     "npm install -g ghcr.io/mcpxyz/mcp-finder || echo 'mcp-finder skipped'",
  #     "npm install -g ghcr.io/mcpxyz/mcp-discovery || echo 'mcp-discovery skipped'",
  #     "npm install -g ghcr.io/mcpxyz/mcp-compass || echo 'mcp-compass skipped'",
  #     "npm install -g ghcr.io/mcpxyz/local-rag || echo 'local-rag skipped'",
  #     "npm install -g ghcr.io/mcpxyz/code-sandbox || echo 'code-sandbox skipped'",
  #     "echo 'MCP servers installed globally'"
  #   ]
  # }

  # ---------------------------------------------------------------------
  # Provisioner 6: Copy system configurations (Root-space)
  # ---------------------------------------------------------------------
  provisioner "file" {
    source      = "${path.root}/../system/caddy/"
    destination = "/tmp/system-caddy/"
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "mkdir -p /etc/caddy",
      "cp /tmp/system-caddy/Caddyfile /etc/caddy/",
      "rm -rf /tmp/system-caddy"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/../system/systemd/"
    destination = "/tmp/system-systemd/"
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "mkdir -p /etc/systemd/system",
      "cp /tmp/system-systemd/opencode-web.service /etc/systemd/system/",
      "cp /tmp/system-systemd/caddy.service /etc/systemd/system/",
      "rm -rf /tmp/system-systemd",
      "systemctl daemon-reload",
      "systemctl enable opencode-web.service",
      "systemctl enable caddy.service"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/../system/network/"
    destination = "/tmp/system-network/"
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "mkdir -p /usr/local/bin",
      "cp /tmp/system-network/init.sh /usr/local/bin/",
      "chmod +x /usr/local/bin/init.sh",
      "rm -rf /tmp/system-network"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner 7: Copy user-space configs
  # ---------------------------------------------------------------------
  provisioner "file" {
    source      = "${path.root}/../home/devuser/"
    destination = "/home/devuser/"
  }

  provisioner "file" {
    source      = "${path.root}/../configs/opencode/opencode.json"
    destination = "/home/devuser/.opencode/opencode.json"
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "chown -R devuser:devuser /home/devuser"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner 8: Force password change on first SSH login
  # ---------------------------------------------------------------------
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "passwd -e devuser || true",
      "sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "systemctl restart sshd"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner 9: Cleanup
  # ---------------------------------------------------------------------
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script = "${path.root}/../scripts/packer/cleanup.sh"
  }

  # ---------------------------------------------------------------------
  # Post-processor: Create manifest
  # ---------------------------------------------------------------------
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
