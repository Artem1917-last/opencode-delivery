# =============================================================================
# OpenCode Delivery - Dockerfile
# =============================================================================
# Base: Ubuntu 24.04 LTS (no external images like pilinux/opencode)
# Includes: OpenCode, Traefik, pre-warmed Docker images
# =============================================================================

FROM ubuntu:24.04

# =============================================================================
# Build arguments
# =============================================================================
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=UTC
ARG OPENCODE_VERSION=latest

# =============================================================================
# Environment
# =============================================================================
ENV TZ=${TZ} \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# =============================================================================
# Labels
# =============================================================================
LABEL maintainer="OpenCode Delivery" \
      description="OpenCode Delivery Docker Image" \
      version="1.0.0"

# =============================================================================
# Install base dependencies
# =============================================================================
RUN apt-get update && apt-get install -y \
    # Essential utilities
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    net-tools \
    dnsutils \
    jq \
    # Cloud-init (for first boot)
    cloud-init \
    cloud-initramfs-growroot \
    # Docker prerequisites
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    # OpenCode prerequisites
    fuse \
    libfuse2 \
    # Misc
    unzip \
    zip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Install Docker
# =============================================================================
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Install OpenCode
# =============================================================================
RUN curl -fsSL https://opencode.ai/api/download/linux -o /tmp/opencode.tar.gz \
    || curl -fsSL https://github.com/opencode-ai/opencode/releases/latest/download/opencode-linux-x64.tar.gz -o /tmp/opencode.tar.gz \
    && tar -xzf /tmp/opencode.tar.gz -C /opt \
    && ln -sf /opt/opencode/bin/opencode /usr/local/bin/opencode \
    && rm /tmp/opencode.tar.gz

# =============================================================================
# Install Traefik v3
# =============================================================================
ARG TRAEFIK_VERSION=v3.2.0
RUN curl -fsSL "https://github.com/traefik/traefik/releases/download/${TRAEFIK_VERSION}/traefik_${TRAEFIK_VERSION}_linux_amd64.tar.gz" -o /tmp/traefik.tar.gz \
    && tar -xzf /tmp/traefik.tar.gz -C /usr/local/bin --strip-components=1 \
    && rm /tmp/traefik.tar.gz

# =============================================================================
# Create directories
# =============================================================================
RUN mkdir -p /home/devuser/configs \
    /home/devuser/opencode-delivery \
    /etc/traefik \
    /letsencrypt \
    /var/log \
    /var/lib/cloud/seed

# =============================================================================
# Copy OpenCode Delivery files
# =============================================================================
COPY home/devuser/configs /home/devuser/configs
COPY home/devuser/opencode-delivery/docker-compose.yml /home/devuser/opencode-delivery/docker-compose.yml

# =============================================================================
# Copy system configurations
# =============================================================================
COPY system/traefik /etc/traefik
COPY system/systemd/opencode.service /etc/systemd/system/opencode.service
COPY system/network/init.sh /usr/local/bin/

# =============================================================================
# Set permissions
# =============================================================================
RUN chmod +x /usr/local/bin/init.sh \
    && chmod 755 /etc/traefik \
    && chmod 600 /etc/traefik/dynamic.yml \
    && chmod 644 /etc/systemd/system/opencode.service \
    && chown -R root:root /home/devuser/configs

# =============================================================================
# Pre-warm Docker images (on first boot via entrypoint)
# =============================================================================
# Note: Cannot run docker pull during build (Docker daemon not available)
# Images are pre-warmed via entrypoint script on first container start

# =============================================================================
# Create devuser user (if not exists)
# =============================================================================
RUN useradd -m -s /bin/bash devuser \
    && usermod -aG sudo,docker devuser \
    && echo "devuser:opencode" | chpasswd

# =============================================================================
# Switch to devuser
# =============================================================================
USER devuser
WORKDIR /home/devuser

# =============================================================================
# Environment for OpenCode
# =============================================================================
ENV OPENCODE_SERVER_PORT=4096 \
    OPENCODE_SERVER_USERNAME=devuser \
    TZ=UTC

# =============================================================================
# Expose ports
# =============================================================================
EXPOSE 4096  # OpenCode web interface
EXPOSE 80    # Traefik HTTP (ACME challenge)
EXPOSE 31415 # Traefik HTTPS

# =============================================================================
# Healthcheck
# =============================================================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:4096/health || exit 1

# =============================================================================
# Default command
# =============================================================================
CMD ["/bin/bash"]
