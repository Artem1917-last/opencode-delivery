#!/bin/bash
# ===========================================
# OpenCode Delivery — VPS Install Script
# Устанавливает решение на VDS клиента
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

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
# Load .env
# ===========================================
load_env() {
    if [ -f "${PROJECT_ROOT}/.env" ]; then
        log_info "Загрузка конфигурации из .env..."
        export $(grep -v '^#' "${PROJECT_ROOT}/.env" | xargs)
    else
        log_error ".env файл не найден!"
        log_info "Скопируйте configs/env.example в .env и настройте."
        exit 1
    fi
}

# ===========================================
# Check prerequisites
# ===========================================
check_prerequisites() {
    log_info "Проверка предварительных требований..."

    if command -v docker >/dev/null 2>&1; then
        log_success "Docker уже установлен"
    else
        log_info "Установка Docker..."
        curl -fsSL https://get.docker.com | sh
        systemctl start docker
        systemctl enable docker
        log_success "Docker установлен"
    fi

    if command -v docker-compose >/dev/null 2>&1 || command -v docker compose >/dev/null 2>&1; then
        log_success "Docker Compose уже установлен"
    else
        log_info "Установка Docker Compose..."
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        log_success "Docker Compose установлен"
    fi
}

# ===========================================
# Pull latest image or build
# ===========================================
setup_images() {
    log_info "Подготовка образов..."

    cd "${PROJECT_ROOT}"

    # Try to pull pre-built image first
    if [ -n "$REGISTRY_IMAGE" ]; then
        docker pull "$REGISTRY_IMAGE" || true
    fi

    # Build if no pre-built image
    docker-compose build

    log_success "Образы готовы"
}

# ===========================================
# Create volumes
# ===========================================
create_volumes() {
    log_info "Создание volumes..."

    docker volume create opencode_data 2>/dev/null || true
    docker volume create opencode_state 2>/dev/null || true
    docker volume create opencode_config 2>/dev/null || true
    docker volume create npm_data 2>/dev/null || true
    docker volume create npm_letsencrypt 2>/dev/null || true

    log_success "Volumes созданы"
}

# ===========================================
# Start containers
# ===========================================
start_containers() {
    log_info "Запуск контейнеров..."

    cd "${PROJECT_ROOT}"

    docker-compose up -d

    # Wait for containers to be ready
    sleep 10

    log_success "Контейнеры запущены"
}

# ===========================================
# Setup Nginx Proxy Manager
# ===========================================
setup_nginx_proxy_manager() {
    log_info "Настройка Nginx Proxy Manager..."

    # Wait for NPM to be ready
    sleep 5

    # NPM default credentials: admin@example.com / changeme
    log_info "Откройте http://localhost:81 для настройки NPM"
    log_info "Логин: admin@example.com"
    log_info "Пароль: changeme"

    log_success "NPM настроен"
}

# ===========================================
# Setup Basic Auth
# ===========================================
setup_basic_auth() {
    log_info "Настройка Basic Auth..."

    # Generate htpasswd
    apt-get update && apt-get install -y apache2-utils 2>/dev/null || true

    local auth_file="${PROJECT_ROOT}/configs/nginx/.htpasswd"
    mkdir -p "$(dirname "$auth_file")"

    htpasswd -bc "$auth_file" "$OPENCODE_SERVER_USERNAME" "$OPENCODE_SERVER_PASSWORD"

    log_success "Basic Auth настроен"
}

# ===========================================
# Configure firewall
# ===========================================
configure_firewall() {
    log_info "Настройка firewall..."

    if command -v ufw >/dev/null 2>&1; then
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow 22/tcp
        ufw enable 2>/dev/null || true
    fi

    log_success "Firewall настроен"
}

# ===========================================
# Print access info
# ===========================================
print_access_info() {
    echo ""
    echo "==========================================="
    echo "  OpenCode установлен и запущен!"
    echo "==========================================="
    echo ""
    echo "Доступ к системе:"
    echo "  URL: http://$(hostname -I | awk '{print $1}'):80"
    echo "  или: http://YOUR_DOMAIN:80"
    echo ""
    echo "Basic Auth:"
    echo "  Логин: $OPENCODE_SERVER_USERNAME"
    echo "  Пароль: (тот что вы указали в .env)"
    echo ""
    echo "Nginx Proxy Manager:"
    echo "  URL: http://localhost:81"
    echo "  Логин: admin@example.com"
    echo "  Пароль: changeme"
    echo ""
    echo "OpenCode Web Interface:"
    echo "  URL: http://localhost:4096"
    echo ""
}

# ===========================================
# Main
# ===========================================
main() {
    echo ""
    echo "==========================================="
    echo "  OpenCode Delivery — VPS Install"
    echo "==========================================="
    echo ""

    load_env
    check_prerequisites
    setup_images
    create_volumes
    setup_basic_auth
    start_containers
    setup_nginx_proxy_manager
    configure_firewall
    print_access_info

    echo ""
    log_success "Установка завершена!"
    echo ""
}

main "$@"
