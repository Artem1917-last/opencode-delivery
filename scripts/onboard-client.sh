#!/bin/bash
# ===========================================
# OpenCode Delivery — Onboard Client Script
# Генерирует документацию и инструкции для клиента
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

# ===========================================
# Load .env
# ===========================================
load_env() {
    if [ -f "${PROJECT_ROOT}/.env" ]; then
        export $(grep -v '^#' "${PROJECT_ROOT}/.env" | xargs)
    fi
}

# ===========================================
# Generate client credentials
# ===========================================
generate_credentials() {
    log_info "Генерация учётных данных для клиента..."

    local creds_file="${PROJECT_ROOT}/documentation/client-credentials.txt"

    cat > "${creds_file}" << EOF
==========================================
OpenCode — Учётные данные
==========================================

URL: ${OPENCODE_DOMAIN:-http://$(hostname -I | awk '{print $1}'):80}

Basic Auth:
  Логин: ${OPENCODE_SERVER_USERNAME:-admin}
  Пароль: ${OPENCODE_SERVER_PASSWORD:-СМЕНИТЕ_ПАРОЛЬ}

==========================================
Важно!
==========================================
1. Смените пароль по умолчанию
2. Сохраните эти данные в безопасном месте
3. Не передавайте их третьим лицам
==========================================
EOF

    log_success "Учётные данные сохранены в documentation/client-credentials.txt"
}

# ===========================================
# Copy documentation
# ===========================================
prepare_documentation() {
    log_info "Подготовка документации..."

    mkdir -p "${PROJECT_ROOT}/documentation/output"

    # Generate README.html if not exists
    if [ ! -f "${PROJECT_ROOT}/documentation/README.html" ]; then
        cat > "${PROJECT_ROOT}/documentation/README.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OpenCode — Быстрый старт</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; line-height: 1.6; }
        h1 { color: #2563eb; border-bottom: 2px solid #2563eb; padding-bottom: 10px; }
        h2 { color: #1e40af; margin-top: 30px; }
        .step { background: #f3f4f6; padding: 15px; border-radius: 8px; margin: 10px 0; }
        .warning { background: #fef3c7; padding: 15px; border-radius: 8px; border-left: 4px solid #f59e0b; }
        code { background: #e5e7eb; padding: 2px 6px; border-radius: 4px; }
        a { color: #2563eb; }
    </style>
</head>
<body>
    <h1>🚀 OpenCode — Быстрый старт</h1>

    <h2>Добро пожаловать!</h2>
    <p>OpenCode — это AI-ассистент для автоматизации вашего бизнеса. Всё уже настроено и готово к работе.</p>

    <h2>Как начать</h2>

    <div class="step">
        <h3>Шаг 1: Откройте интерфейс</h3>
        <p>Введите адрес сервера в браузере. Вам потребуется ввести логин и пароль (см. documentation/client-credentials.txt).</p>
    </div>

    <div class="step">
        <h3>Шаг 2: Выберите AI-провайдер</h3>
        <p>При первом входе выберите провайдера:</p>
        <ul>
            <li><strong>Antigravity</strong> — бесплатный, работает из коробки</li>
            <li><strong>Gemini</strong> — требует API ключ от Google</li>
        </ul>
    </div>

    <div class="step">
        <h3>Шаг 3: Начните работу</h3>
        <p>Просто напишите вашу задачу в чате. Агент поможет:</p>
        <ul>
            <li>Написать и отредактировать код</li>
            <li>Создать документацию</li>
            <li>Автоматизировать процессы</li>
            <li>Найти информацию</li>
        </ul>
    </div>

    <h2>Полезные команды</h2>
    <table style="width: 100%; border-collapse: collapse;">
        <tr><td><code>/agents</code></td><td>Список всех агентов</td></tr>
        <tr><td><code>/skills</code></td><td>Список всех навыков</td></tr>
        <tr><td><code>/help</code></td><td>Справка</td></tr>
    </table>

    <div class="warning">
        <strong>⚠️ Важно:</strong> Все ваши проекты сохраняются в git. Не забывайте пушить изменения!
    </div>

    <h2>Документация</h2>
    <ul>
        <li><a href="getting-started.pdf">Быстрый старт (PDF)</a></li>
        <li><a href="quick-reference.pdf">Шпаргалка (PDF)</a></li>
        <li><a href="faq.pdf">Частые вопросы (PDF)</a></li>
    </ul>

    <hr style="margin: 30px 0;">
    <p style="color: #6b7280; font-size: 14px;">OpenCode Delivery Solution v1.0</p>
</body>
</html>
HTMLEOF
    fi

    log_success "Документация подготовлена"
}

# ===========================================
# Main
# ===========================================
main() {
    echo ""
    echo "==========================================="
    echo "  OpenCode Delivery — Onboard Client"
    echo "==========================================="
    echo ""

    load_env
    generate_credentials
    prepare_documentation

    echo ""
    log_success "Онбординг завершён!"
    echo ""
    echo "Отправьте клиенту:"
    echo "  - documentation/client-credentials.txt"
    echo "  - documentation/README.html"
    echo ""
}

main "$@"
