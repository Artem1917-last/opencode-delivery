# syntax=docker/dockerfile:1
FROM pilinux/opencode-docker:latest

# ===========================================
# Labels
# ===========================================
LABEL maintainer="OpenCode Delivery Solution"
LABEL description="Pre-configured OpenCode for micro-business automation"
LABEL version="1.0.0"

# ===========================================
# Arguments
# ===========================================
ARG USER=opencode
ARG GROUP=opencode
ARG UID=1000
ARG GID=1000

# ===========================================
# Install system dependencies
# ===========================================
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    htop \
    jq \
    unzip \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# ===========================================
# Create user
# ===========================================
RUN groupadd -g ${GID} ${GROUP} && \
    useradd -u ${UID} -g ${GROUP} -m -s /bin/bash ${USER}

# ===========================================
# Install Node.js (for olore and npm packages)
# ===========================================
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# ===========================================
# Install olore (documentation CLI)
# ===========================================
RUN npm install -g @olorehq/olore

# ===========================================
# Install OpenCode CLI tools
# ===========================================
RUN npm install -g @plannotator/opencode @openspoon/subtask2

# ===========================================
# Install Agent Memory plugin
# ===========================================
RUN npm install -g @opencode/agent-memory || true

# ===========================================
# Install AI Auth providers
# ===========================================
RUN npm install -g @opencode/antigravity-auth || true
RUN npm install -g @opencode/gemini-auth || true

# ===========================================
# Create directories for configs
# ===========================================
RUN mkdir -p /home/${USER}/.config/opencode/agents \
              /home/${USER}/.config/opencode/skills \
              /home/${USER}/.config/opencode/plugins \
              /home/${USER}/.config/opencode/mcp \
              /home/${USER}/documentation

# ===========================================
# Set ownership
# ===========================================
RUN chown -R ${USER}:${GROUP} /home/${USER}

# ===========================================
# Switch to user
# ===========================================
USER ${USER}

# ===========================================
# Pre-install documentation (olore)
# ===========================================
RUN olore install opencode || echo "olore install skipped"

# ===========================================
# Copy agent configurations
# COPY --chown=${UID}:${GID} configs/agents/ /home/${USER}/.config/opencode/agents/
# COPY --chown=${UID}:${GID} configs/skills/ /home/${USER}/.config/opencode/skills/

# ===========================================
# Copy MCP server configurations
# COPY --chown=${UID}:${GID} configs/mcp/ /home/${USER}/.config/opencode/mcp/

# ===========================================
# Copy documentation
# COPY --chown=${UID}:${GID} documentation/ /home/${USER}/documentation/

# ===========================================
# Install Agency Agents (144 agents)
# ===========================================
WORKDIR /tmp/agency
RUN git clone --recurse-submodules https://github.com/msitarzewski/agency-agents.git . && \
    ./scripts/convert.sh --tool opencode && \
    ./scripts/install.sh --tool opencode && \
    rm -rf /tmp/agency

# ===========================================
# Install MCP servers (global npm packages as fallback)
# ===========================================
WORKDIR /tmp/mcp
RUN npm install -g @modelcontextprotocol/server-filesystem || true
RUN npm install -g @modelcontextprotocol/server-github || true
RUN npm install -g @modelcontextprotocol/server-playwright || true
RUN npm install -g mcp-finder mcp-server-discovery mcp-compass || true
RUN npm install -g google-workspace-mcp telegram-mcp || true
RUN npm install -g mcp-local-rag node-code-sandbox-mcp || true
RUN rm -rf /tmp/mcp

# ===========================================
# Switch back to root for final setup
# ===========================================
USER root

# ===========================================
# Install MCP servers for Agency (Python-based)
# ===========================================
RUN pip3 install mcp-server-discovery mcp-compass || true
RUN pip3 install google-workspace-mcp telegram-mcp || true

# ===========================================
# Set final ownership
# ===========================================
RUN chown -R ${USER}:${GROUP} /home/${USER}

# ===========================================
# Expose ports
# ===========================================
EXPOSE 4096

# ===========================================
# Health check
# ===========================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:4096/health || exit 1

# ===========================================
# Default command
# ===========================================
CMD ["opencode", "server", "--host", "0.0.0.0"]
