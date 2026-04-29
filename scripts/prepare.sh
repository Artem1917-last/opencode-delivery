#!/bin/bash
# ===========================================
# OpenCode Delivery — Prepare Script
# Stage 1: Выполняется ОДИН раз для подготовки решения
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
# Fork opencode-delivery repo
# ===========================================
fork_repo() {
    log_info "Форк репозитория opencode-delivery..."

    if [ -z "$GITHUB_TOKEN" ]; then
        log_warn "GITHUB_TOKEN не установлен. Пропускаем форк."
        log_info "Сделайте форк вручную: https://github.com/YOUR_ORG/opencode-delivery"
        return 0
    fi

    # Fork via GitHub CLI
    if command -v gh >/dev/null 2>&1; then
        gh repo fork --clone=false opencode-delivery 2>/dev/null || true
        log_success "Форк выполнен"
    else
        log_info "GitHub CLI не найден. Сделайте форк вручную."
    fi
}

# ===========================================
# Install olore globally
# ===========================================
install_olore() {
    log_info "Установка olore..."

    npm install -g @olorehq/olore 2>/dev/null || true

    log_success "olore установлен"
}

# ===========================================
# Install documentation skill
# ===========================================
install_documentation() {
    log_info "Установка документации OpenCode..."

    olore install opencode 2>/dev/null || true

    log_success "Документация установлена"
}

# ===========================================
# Add base plugins
# ===========================================
install_plugins() {
    log_info "Установка базовых плагинов..."

    npm install -g @opencode/agent-memory 2>/dev/null || true
    npm install -g @opencode/antigravity-auth 2>/dev/null || true
    npm install -g @opencode/gemini-auth 2>/dev/null || true

    log_success "Плагины установлены"
}

# ===========================================
# Setup configs directory structure
# ===========================================
setup_configs() {
    log_info "Настройка структуры конфигов..."

    mkdir -p "${PROJECT_ROOT}/configs/opencode"
    mkdir -p "${PROJECT_ROOT}/configs/agents"
    mkdir -p "${PROJECT_ROOT}/configs/mcp"
    mkdir -p "${PROJECT_ROOT}/configs/skills"
    mkdir -p "${PROJECT_ROOT}/configs/plugins"
    mkdir -p "${PROJECT_ROOT}/configs/traefik"

    log_success "Структура конфигов создана"
}

# ===========================================
# Create base repository on GitHub
# ===========================================
create_github_repo() {
    log_info "Создание GitHub репозитория..."

    if [ -z "$GITHUB_TOKEN" ]; then
        log_warn "GITHUB_TOKEN не установлен. Пропускаем создание репозитория."
        log_info "Создайте репозиторий вручную на GitHub."
        return 0
    fi

    if command -v gh >/dev/null 2>&1; then
        gh repo create opencode-delivery --public --clone=false 2>/dev/null || true
        log_success "Репозиторий создан"
    else
        log_info "GitHub CLI не найден. Создайте репозиторий вручную."
    fi
}

# ===========================================
# Save to Git
# ===========================================
save_to_git() {
    log_info "Инициализация git..."

    cd "${PROJECT_ROOT}"

    git init
    git add .
    git commit -m "Initial commit: OpenCode Delivery Solution v1.0"

    log_success "Git инициализирован"
    log_info "Добавьте remote и запушьте: git remote add origin https://github.com/YOUR_ORG/opencode-delivery.git"
}

# ===========================================
# Print next steps
# ===========================================
print_next_steps() {
    echo ""
    echo "==========================================="
    echo "  Stage 1 завершена!"
    echo "==========================================="
    echo ""
    echo "Следующие шаги:"
    echo ""
    echo "  1. Настройте .env файл:"
    echo "     cp configs/env.example .env"
    echo "     # Отредактируйте .env"
    echo ""
    echo "  2. Запушьте в GitHub:"
    echo "     git remote add origin https://github.com/YOUR_ORG/opencode-delivery.git"
    echo "     git push -u origin master"
    echo ""
    echo "  3. Перейдите к Stage 2 (установка на VPS):"
    echo "     ./scripts/install-vps.sh"
    echo ""
}

# ===========================================
# Main
# ===========================================
main() {
    echo ""
    echo "==========================================="
    echo "  OpenCode Delivery — Prepare"
    echo "  Stage 1: Подготовка решения"
    echo "==========================================="
    echo ""

    check_prerequisites
    fork_repo
    install_olore
    install_documentation
    install_plugins
    setup_configs
    create_github_repo
    save_to_git
    print_next_steps

    echo ""
    log_success "Подготовка завершена!"
    echo ""
}

main "$@"