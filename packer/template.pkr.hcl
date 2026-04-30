# =============================================================================
# OpenCode Delivery - Packer Template for FirstVDS (QEMU/KVM)
# =============================================================================
# Target: Debian 12.10.0 netinst on FirstVDS KVM
# Boot: Legacy BIOS
# Output: .qcow2 image (converted to ISO for FirstVDS delivery)
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
  default   = "packer"  # Temporary password for Packer build
  sensitive = true
  description = "SSH password (temporary - client must change after deployment)"
}

variable "disk_size" {
  type        = number
  default     = 40960  # 40GB
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
  # Boot configuration - d-i automated install via HTTP
  boot_wait    = "5s"
  boot_command = [
    "<tab><wait>",
    "auto=true priority=critical url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg net.ifnames=0",
    "<enter>"
  ]

  # HTTP server for preseed file (replaces unreliable floppy)
  http_directory = "${path.root}/../scripts/packer"

  # Serial console output via machine_type (pc) default behavior

  # ISO configuration
  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  # Machine type - Legacy BIOS (pc, not q35)
  machine_type = "pc"

  # Disk configuration
  disk_size         = var.disk_size
  output_directory   = "output-debian12"
  disk_image        = false
  format            = "qcow2"

  # Hardware - VirtIO drivers built into Debian 12 kernel
  memory            = var.memory
  cpus              = var.cpus
  net_device        = "virtio-net-pci"
  disk_interface    = "virtio"

  # Display
  display           = "none"
  headless          = var.headless

  # VNC for debugging (bind to all interfaces for tunnel access)
  vnc_bind_address  = "0.0.0.0"
  vnc_port_min      = 5910
  vnc_port_max      = 5919

  # Communicator (SSH) - for provisioners
  communicator      = "ssh"
  ssh_port          = 22
  ssh_timeout       = "30m"
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  ssh_handshake_attempts = 100
  ssh_disable_agent_forwarding = true

  # QEMU binary
  qemu_binary       = "C:/Program Files/qemu/qemu-system-x86_64.exe"

  # Acceleration - KVM for nested virtualization
  accelerator       = "whpx"

  # CPU features
  cpu_model         = "qemu64"

  # VM name
  vm_name           = "opencode-debian12.qcow2"
}

# =============================================================================
# Build Section
# =============================================================================

build {
  name = "opencode-delivery"

  sources = ["source.qemu.debian12"]

  # ---------------------------------------------------------------------
  # Provisioner: Wait for installation to complete and reboot
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
  # Provisioner: Install Docker (via official repository, not distro packages)
  # ---------------------------------------------------------------------
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    expect_disconnect = true
    pause_before = "10s"
    inline = [
      # Install prerequisites
      "apt-get update",
      "apt-get install -y ca-certificates curl gnupg",
      # Add Docker GPG key
      "install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "chmod a+r /etc/apt/keyrings/docker.gpg",
      # Add Docker repository
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" > /etc/apt/sources.list.d/docker.list",
      # Install Docker Engine and Docker Compose plugin
      "apt-get update",
      "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      # Add devuser to docker group
      "usermod -aG docker devuser",
      "echo 'Docker installed successfully'"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner: Install essential packages
  # ---------------------------------------------------------------------
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "apt-get install -y curl wget git unzip jq htop net-tools dnsutils vim nano sudo systemd systemd-sysv",
      "echo 'Essential packages installed'"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner: Copy system configurations (Root-space)
  # ---------------------------------------------------------------------
  provisioner "file" {
    source      = "${path.root}/../system/traefik/"
    destination = "/tmp/system-traefik/"
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "mkdir -p /etc/traefik",
      "cp -r /tmp/system-traefik/* /etc/traefik/",
      "rm -rf /tmp/system-traefik"
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
      "cp /tmp/system-systemd/opencode.service /etc/systemd/system/",
      "rm -rf /tmp/system-systemd",
      "systemctl daemon-reload"
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
  # Provisioner: Copy user-space configs
  # ---------------------------------------------------------------------
  provisioner "file" {
    source      = "${path.root}/../home/devuser/"
    destination = "/home/devuser/"
  }

  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "chown -R devuser:devuser /home/devuser"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner: Force password change on first SSH login
  # ---------------------------------------------------------------------
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      # Force SSH to require password change on first login
      "passwd -e devuser || true",
      # Make sshd config allow password auth
      "sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "systemctl restart sshd"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner: Pull Docker images (Pre-warm)
  # ---------------------------------------------------------------------
  provisioner "shell" {
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    expect_disconnect = true
    pause_before = "30s"
    inline = [
      "echo 'Pre-warming Docker images...'",
      "docker pull ghcr.io/opencode-ai/opencode:latest || echo 'OpenCode image pull skipped'",
      "docker pull traefik:v3.2 || echo 'Traefik image pull skipped'",
      "docker pull ghcr.io/mcpxyz/filesystem:latest || echo 'filesystem MCP skipped'",
      "docker pull ghcr.io/mcpxyz/github:latest || echo 'github MCP skipped'",
      "docker pull ghcr.io/mcpxyz/playwright:latest || echo 'playwright MCP skipped'",
      "docker pull ghcr.io/mcpxyz/mcp-finder:latest || echo 'mcp-finder skipped'",
      "docker pull ghcr.io/mcpxyz/mcp-discovery:latest || echo 'mcp-discovery skipped'",
      "docker pull ghcr.io/mcpxyz/mcp-compass:latest || echo 'mcp-compass skipped'",
      "docker pull ghcr.io/mcpxyz/google-workspace:latest || echo 'google-workspace skipped'",
      "docker pull ghcr.io/mcpxyz/telegram:latest || echo 'telegram MCP skipped'",
      "docker pull ghcr.io/mcpxyz/local-rag:latest || echo 'local-rag skipped'",
      "docker pull ghcr.io/mcpxyz/code-sandbox:latest || echo 'code-sandbox skipped'",
      "echo 'Docker pre-warm complete (12 images)'"
    ]
  }

  # ---------------------------------------------------------------------
  # Provisioner: Cleanup (Build-time only)
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
