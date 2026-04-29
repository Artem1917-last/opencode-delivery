#!/bin/bash
# ===========================================
# OpenCode Delivery — VPS Install Script
# Stage 2: Устанавливает решение на VDS клиента
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
# Generate password if not set
# ===========================================
generate_password_if_needed() {
    if [ -z "$OPENCODE_SERVER_PASSWORD" ] || [ "$OPENCODE_SERVER_PASSWORD" = "CHANGE_ME" ]; then
        log_info "Генерация пароля..."
        OPENCODE_SERVER_PASSWORD=$(bash "${SCRIPT_DIR}/generate-password.sh")
        log_success "Пароль сгенерирован: $OPENCODE_SERVER_PASSWORD"

        # Save to .env
        if [ -f "${PROJECT_ROOT}/.env" ]; then
            sed -i "s/OPENCODE_SERVER_PASSWORD=.*/OPENCODE_SERVER_PASSWORD=${OPENCODE_SERVER_PASSWORD}/" "${PROJECT_ROOT}/.env"
        fi
    fi

    if [ -z "$OPENCODE_SERVER_USERNAME" ]; then
        OPENCODE_SERVER_USERNAME="admin"
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
# Create directories for Traefik
# ===========================================
create_traefik_dirs() {
    log_info "Создание директорий для Traefik..."

    mkdir -p "${PROJECT_ROOT}/configs/traefik"
    mkdir -p "${PROJECT_ROOT}/configs/traefik/acme"
    mkdir -p "${PROJECT_ROOT}/configs/traefik/auth"

    # Create empty ACME file for Traefik
    touch "${PROJECT_ROOT}/configs/traefik/acme/acme.json"
    chmod 600 "${PROJECT_ROOT}/configs/traefik/acme/acme.json"

    log_success "Директории созданы"
}

# ===========================================
# Generate Basic Auth password file for Traefik
# ===========================================
setup_basic_auth() {
    log_info "Настройка Basic Auth..."

    # Install apache2-utils for htpasswd
    apt-get update && apt-get install -y apache2-utils 2>/dev/null || true

    local auth_file="${PROJECT_ROOT}/configs/traefik/auth/htpasswd"
    mkdir -p "$(dirname "$auth_file")"

    # Generate password if needed
    generate_password_if_needed

    # Create htpasswd file (Traefik uses APR1 format by default)
    htpasswd -bc "$auth_file" "$OPENCODE_SERVER_USERNAME" "$OPENCODE_SERVER_PASSWORD"

    log_success "Basic Auth настроен"
    log_info "Логин: $OPENCODE_SERVER_USERNAME"
    log_info "Пароль: $OPENCODE_SERVER_PASSWORD"
}

# ===========================================
# Build images
# ===========================================
setup_images() {
    log_info "Сборка образов..."

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

    log_success "Volumes созданы"
}

# ===========================================
# Configure firewall
# ===========================================
configure_firewall() {
    log_info "Настройка firewall..."

    if command -v ufw >/dev/null 2>&1; then
        ufw allow 80/tcp    # HTTP (Let's Encrypt)
        ufw allow 443/tcp   # HTTPS
        ufw allow 31415/tcp # Traefik dashboard
        ufw allow 22/tcp    # SSH
        ufw --force enable 2>/dev/null || true
        log_success "Firewall настроен (порты 80, 443, 31415 открыты)"
    else
        log_warn "UFW не найден. Откройте порты вручную:"
        log_info "  80/tcp — HTTP (Let's Encrypt)"
        log_info "  443/tcp — HTTPS"
        log_info "  31415/tcp — Traefik Dashboard"
    fi
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
# Verify setup
# ===========================================
verify_setup() {
    log_info "Проверка установки..."

    local ip=$(hostname -I | awk '{print $1}')

    # Check if containers are running
    if docker ps | grep -q opencode-server; then
        log_success "OpenCode контейнер запущен"
    else
        log_error "OpenCode контейнер не запущен!"
        return 1
    fi

    if docker ps | grep -q traefik; then
        log_success "Traefik контейнер запущен"
    else
        log_error "Traefik контейнер не запущен!"
        return 1
    fi

    # Check Traefik HTTP challenge port
    if curl -sf "http://${ip}:80/health" >/dev/null 2>&1; then
        log_success "HTTP порт (80) работает"
    fi
}

# ===========================================
# Print access info
# ===========================================
print_access_info() {
    local ip=$(hostname -I | awk '{print $1}')

    echo ""
    echo "==========================================="
    echo "  OpenCode установлен и запущен!"
    echo "==========================================="
    echo ""
    echo "Доступ к системе:"
    echo "  URL: https://${ip}:31415"
    echo "  или: https://YOUR_DOMAIN"
    echo ""
    echo "Traefik Dashboard:"
    echo "  URL: http://${ip}:31415"
    echo ""
    echo "Basic Auth:"
    echo "  Логин: $OPENCODE_SERVER_USERNAME"
    echo "  Пароль: $OPENCODE_SERVER_PASSWORD"
    echo ""
    echo "Важно:"
    echo "  - HTTPS работает через Let's Encrypt (автоматически)"
    echo "  - Для домена: создайте A-запись на ${ip}"
    echo "  - Пароль хранится в .env файле"
    echo ""
}

# ===========================================
# Main
# ===========================================
main() {
    echo ""
    echo "==========================================="
    echo "  OpenCode Delivery — VPS Install"
    echo "  Stage 2: Установка на VDS"
    echo "==========================================="
    echo ""

    load_env
    generate_password_if_needed
    check_prerequisites
    create_traefik_dirs
    setup_basic_auth
    setup_images
    create_volumes
    start_containers
    configure_firewall
    verify_setup
    print_access_info

    echo ""
    log_success "Установка завершена!"
    echo ""
    echo "Следующий шаг: ./scripts/onboard-client.sh"
    echo ""
}

main "$@"