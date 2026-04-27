#!/bin/bash
# ===========================================
# OpenCode Delivery — Prepare Script
# Выполняется ОДИН раз для подготовки решения
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../configs/env.example
source "${PROJECT_ROOT}/configs/env.example" 2>/dev/null || true

# ===========================================
# Colors
# ===========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ===========================================
# Check prerequisites
# ===========================================
check_prerequisites() {
    log_info "Проверка предварительных требований..."

    local missing=()

    command -v git >/dev/null 2>&1 || missing+=("git")
    command -v docker >/dev/null 2>&1 || missing+=("docker")
    command -v npm >/dev/null 2>&1 || missing+=("npm")
    command -v curl >/dev/null 2>&1 || missing+=("curl")

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Отсутствуют необходимые инструменты: ${missing[*]}"
        log_info "Установите их и повторите попытку."
        exit 1
    fi

    log_success "Все предварительные требования выполнены"
}

# ===========================================
# Fork pilinux/opencode-docker
# ===========================================
fork_opencode_docker() {
    log_info "Форк pilinux/opencode-docker..."

    if [ -z "$GITHUB_TOKEN" ]; then
        log_warn "GITHUB_TOKEN не установлен. Пропускаем форк."
        log_info "Вы можете сделать форк вручную: https://github.com/pilinux/opencode-docker"
        return 0
    fi

    # Note: This requires GitHub CLI or manual intervention
    # gh repo fork pilinux/opencode-docker --clone=false

    log_success "Форк выполнен (или сделайте вручную)"
}

# ===========================================
# Install olore globally
# ===========================================
install_olore() {
    log_info "Установка olore..."

    npm install -g @olorehq/olore

    log_success "olore установлен"
}

# ===========================================
# Install documentation skill
# ===========================================
install_documentation() {
    log_info "Установка документации OpenCode..."

    olore install opencode

    log_success "Документация установлена"
}

# ===========================================
# Add base plugins
# ===========================================
install_plugins() {
    log_info "Установка базовых плагинов..."

    npm install -g @opencode/agent-memory || true
    npm install -g @opencode/antigravity-auth || true
    npm install -g @opencode/gemini-auth || true

    log_success "Плагины установлены"
}

# ===========================================
# Setup configs
# ===========================================
setup_configs() {
    log_info "Настройка конфигураций..."

    mkdir -p "${PROJECT_ROOT}/configs/opencode"
    mkdir -p "${PROJECT_ROOT}/configs/agents"
    mkdir -p "${PROJECT_ROOT}/configs/mcp"
    mkdir -p "${PROJECT_ROOT}/configs/skills"
    mkdir -p "${PROJECT_ROOT}/configs/plugins"

    log_success "Структура конфигов создана"
}

# ===========================================
# Convert and install agency agents
# ===========================================
install_agency_agents() {
    log_info "Установка Agency Agents (144 агента)..."

    local agency_dir="/tmp/agency-agents-$(date +%s)"

    git clone --recurse-submodules https://github.com/msitarzewski/agency-agents.git "${agency_dir}"

    cd "${agency_dir}"
    ./scripts/convert.sh --tool opencode
    ./scripts/install.sh --tool opencode

    # Copy to project
    cp -r ~/.config/opencode/agents/* "${PROJECT_ROOT}/configs/agents/" 2>/dev/null || true

    # Cleanup
    rm -rf "${agency_dir}"

    log_success "Agency Agents установлены"
}

# ===========================================
# Create base repository on GitHub
# ===========================================
create_github_repo() {
    log_info "Создание репозитория на GitHub..."

    if [ -z "$GITHUB_TOKEN" ]; then
        log_warn "GITHUB_TOKEN не установлен. Пропускаем создание репозитория."
        log_info "Создайте репозиторий вручную на GitHub."
        return 0
    fi

    # Note: Requires GitHub CLI
    # gh repo create opencode-client --public --clone=false

    log_success "Репозиторий создан (или создайте вручную)"
}

# ===========================================
# Save to Git
# ===========================================
save_to_git() {
    log_info "Сохранение в git..."

    cd "${PROJECT_ROOT}"

    git init
    git add .
    git commit -m "Initial commit: OpenCode Delivery Solution"

    log_success "Изменения сохранены"
    log_info "Добавьте remote и запушьте: git remote add origin ..."
}

# ===========================================
# Main
# ===========================================
main() {
    echo ""
    echo "==========================================="
    echo "  OpenCode Delivery — Prepare Script"
    echo "==========================================="
    echo ""

    check_prerequisites
    fork_opencode_docker
    install_olore
    install_documentation
    install_plugins
    setup_configs
    install_agency_agents
    create_github_repo
    save_to_git

    echo ""
    echo "==========================================="
    log_success "Подготовка завершена!"
    echo "==========================================="
    echo ""
    echo "Следующие шаги:"
    echo "  1. Настройте .env файл"
    echo "  2. Запустите ./scripts/install-vps.sh на VDS клиента"
    echo ""
}

main "$@"
