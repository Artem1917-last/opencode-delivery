# OpenCode Delivery Solution

Готовое решение для автоматизации микро-бизнеса. Пользователь создаёт VDS, мы устанавливаем OpenCode в Docker — он входит и начинает работать. Без терминала, без IT-знаний.

## Быстрый старт

```bash
# Клонировать репозиторий
git clone https://github.com/YOUR_ORG/opencode-delivery.git
cd opencode-delivery

# Настроить конфигурацию
cp configs/env.example .env
# Отредактируйте .env под ваши параметры

# Запустить установку
./scripts/install.sh
```

## Что входит в комплект

### Агенты (144 агента)
Полный набор из [agency-agents](https://github.com/msitarzewski/agency-agents) — 12 divisions, все конвертированы для OpenCode.

### Скиллы (Skills)
- `olore-opencode-latest` — локальная документация OpenCode
- `opencode-agent-skills` — динамическая загрузка скиллов
- `mcp-finder` — поиск MCP серверов
- `opencode-skill-generator` — генерация конфигов OpenCode
- Agent Memory — запоминание контекста между сессиями

### MCP серверы
- filesystem-mcp — безопасный доступ к файлам
- github-mcp — интеграция с GitHub
- mcp-server-discovery — поиск MCP серверов
- mcp-compass — рекомендации по выбору MCP
- google-workspace-mcp — Gmail, Calendar, Drive, Docs
- telegram-mcp — Telegram от имени пользователя
- mcp-local-rag — приватный RAG сервер
- playwright-mcp — браузерная автоматизация
- node-code-sandbox-mcp — безопасное выполнение кода

### Плагины
- Agent Memory
- @plannotator/opencode
- @openspoon/subtask2
- Antigravity Auth / Gemini Auth

## Структура проекта

```
opencode-delivery/
├── ADRs/                    # Architecture Decision Records
├── configs/
│   ├── agents/              # Агенты (144 шт.)
│   ├── mcp/                 # MCP серверы
│   ├── nginx/               # Nginx конфиги
│   ├── opencode/            # Конфигурация OpenCode
│   └── skills/              # Скиллы
├── documentation/           # Документация для клиента
├── scripts/                 # Установочные скрипты
├── Dockerfile
└── docker-compose.yml
```

## Установка

### Предварительные требования
- VDS с Ubuntu 20.04+
- Docker и Docker Compose
- SSH доступ (или доступ через хостинг-провайдера)

### Этапы установки

1. **Подготовка (выполняется один раз)**
   ```bash
   ./scripts/prepare.sh
   ```
   - Форк репозитория
   - Установка npm пакетов (olore)
   - Генерация агентов из agency-agents

2. **Установка на VDS клиента**
   ```bash
   ./scripts/install-vps.sh
   ```
   - Установка Docker
   - Запуск контейнера
   - Настройка Nginx Proxy Manager
   - Конфигурация Basic Auth

3. **Передача клиенту**
   ```bash
   ./scripts/onboard-client.sh
   ```
   - Генерация документации
   - Отправка инструкций

## Конфигурация

### Переменные окружения (.env)

```env
# OpenCode Server
OPENCODE_SERVER_USERNAME=admin
OPENCODE_SERVER_PASSWORD=<generate-secure-password>

# Timezone
TZ=Europe/Moscow

# AI Provider
AI_PROVIDER=antigravity  # antigravity | gemini | custom

# Domain
OPENCODE_DOMAIN=opencode.example.com

# Nginx Proxy Manager
NPM_HOST=npm.example.com
NPM_ADMIN_USER=admin
NPM_ADMIN_PASSWORD=<password>
```

## volumes

Данные сохраняются в:
- `opencode_data` — сессии, auth, конфиги пользователя
- `npm_data` — Nginx Proxy Manager данные

## Backup

Клиент управляет бэкапами через git. Все изменения репозитория коммитятся и пушаются на GitHub.

## License

MIT
