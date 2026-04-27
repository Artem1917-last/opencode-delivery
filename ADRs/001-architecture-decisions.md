# ADR-001: Docker-based Deployment

## Status
Accepted

## Context
Наше решение должно быть "plug and play" для нетехнических клиентов. Клиент создаёт VDS, мы устанавливаем OpenCode. Необходимо обеспечить:
- Изоляцию от хост-системы
- Простую установку без терминала для клиента
- Воспроизводимое окружение

## Decision
Используем Docker контейнер с Docker Compose для оркестрации.

### Компоненты:
1. **opencode-server** — основной контейнер с OpenCode
2. **nginx-proxy-manager** — reverse proxy с Basic Auth
3. **volumes** — персистентное хранение данных

### Структура сети:
```
Internet → NPM (port 80/443) → OpenCode (port 4096)
```

## Consequences

### Pros
- Клиент получает готовое окружение "из коробки"
- Данные сохраняются между перезапусками
- Легко масштабировать
- Изоляция от хост-системы

### Cons
- Требует базовых знаний Docker (но это наша работа, не клиента)
- Дополнительные ресурсы (CPU/RAM)

---

## ADR-002: Repository-first Setup для DevOps Automator

## Status
Accepted

## Context
DevOps Automator из agency-agents каждый раз создаёт репозитории с нуля. Для нашего use case это избыточно — репозиторий создаётся один раз и затем используется всеми агентами.

## Decision
Репозиторий создаётся **один раз** на этапе подготовки. DevOps Automator будет:
1. Скачивать готовый репозиторий с GitHub
2. Использовать его как шаблон для новых проектов
3. Пушить изменения в существующий репозиторий

### Implementation:
```
prepare.sh:
  1. Создать репозиторий на GitHub
  2. Инициализировать базовую структуру
  3. Сделать initial commit
  4. Передать URL DevOps Automator
```

## Consequences

### Pros
- DevOps Automator работает быстрее (не создаёт с нуля)
- Историю изменений видно сразу
- Единая точка входа для всех проектов

### Cons
- Требует GitHub integration на этапе подготовки
- Один репозиторий может стать bottleneck для нескольких проектов

### Mitigation
Клиент может создать отдельный репозиторий для каждого проекта позже.

---

## ADR-003: Authentication — User-Selectable Provider

## Status
Accepted

## Context
Клиенты могут иметь разные предпочтения по AI провайдерам. Некоторые хотят бесплатный Antigravity, другие — Google Gemini, третьи — свой кастомный провайдер.

## Decision
AI провайдер **не хардкодится**. Вместо этого:
1. Предустановлены **оба** провайдера (Antigravity + Gemini Auth)
2. Клиент выбирает в интерфейсе OpenCode
3. Конфигурация хранится в `opencode_data` (не в образе)

### Providers:
- `antigravity` — бесплатный,，不需要 API key
- `gemini` — Google AI, требует API key
- `custom` — любой OpenAI-compatible API

## Consequences

### Pros
- Гибкость для клиента
- Можно менять провайдера без переустановки
- Нет vendor lock-in

### Cons
- Клиент должен понимать разницу между провайдерами
- Больше конфигурации для клиента

---

## ADR-004: Full Agency Agents (144 agents)

## Status
Accepted

## Context
Документ описывает 12 divisions с 144 агентами. Возникает вопрос — устанавливать все или только критичные?

## Decision
**Устанавливаем все 144 агента** из agency-agents.

### Reasoning:
1. Размер не критичен (текстовые файлы)
2. "Всё включено" проще для понимания
3. Клиент может попросить любого агента
4. Нет необходимости фильтровать

### Agents Structure:
```
configs/agents/
├── engineering/      # 30+ agents
├── design/          # 8 agents
├── marketing/       # 27 agents
├── sales/           # 9 agents
├── specialized/     # 30+ agents
└── ... (8 more divisions)
```

## Consequences

### Pros
- "Всё из коробки"
- Простая модель для клиента
- Легко документировать

### Cons
- Много файлов (но это не проблема)
- Некоторые агенты могут быть не нужны конкретному клиенту

---

## ADR-005: All MCP Servers Pre-installed

## Status
Accepted

## Context
Документ перечисляет много MCP серверов. Клиент должен иметь доступ "из коробки" к filesystem, GitHub, Google Workspace, Telegram, RAG, Playwright.

## Decision
**Все перечисленные MCP серверы предустановлены:**

### Critical:
- filesystem-mcp
- github-mcp
- mcp-server-discovery
- mcp-compass

### Communication:
- google-workspace-mcp
- telegram-mcp

### Privacy-First RAG:
- mcp-local-rag

### Code Execution:
- node-code-sandbox-mcp

### Browser Automation:
- playwright-mcp
- mcp-playwright

### Search:
- mcp-finder (для поиска дополнительных MCP)

## Consequences

### Pros
- Клиент сразу может работать с любым сервисом
- Не нужно устанавливать MCP вручную
- Единая точка настройки

### Cons
- Большой размер образа
- Некоторые MCP требуют credentials (google-workspace, telegram)

### Mitigation
Credentials запрашиваются при первом использовании через secure input.

---

## ADR-006: Client Documentation as Static Files

## Status
Accepted

## Context
Клиент — не программист. Ему нужна документация которая работает без терминала.

## Decision
Документация — **статичные файлы в контейнере:**
- PDF для печати/чтения
- HTML для просмотра в браузере

### Structure:
```
documentation/
├── README.html          # Главная страница
├── getting-started.pdf  # Быстрый старт
├── quick-reference.pdf   # Шпаргалка
└── faq.pdf              # Частые вопросы
```

## Consequences

### Pros
- Работает без интернета
- Легко открыть в браузере
- Профессиональный вид

### Cons
- Статичная — не обновляется автоматически
- Нужно пересобирать образ при обновлении

### Mitigation
Ссылка на онлайн-документацию включена в PDF.

---

## ADR-007: Nginx Proxy Manager + Basic Auth

## Status
Accepted

## Context
Клиент заходит через браузер. Нужен reverse proxy и авторизация.

## Decision
**Nginx Proxy Manager (NPM)** для:
1. Reverse proxy на port 4096
2. Basic Auth для первого уровня защиты
3. Let's Encrypt для SSL (если есть домен)

### Ports:
- 80 → HTTP (redirect to HTTPS)
- 443 → HTTPS (если настроен домен)
- 4096 → OpenCode (internal only)

### Auth Flow:
```
Client → NPM:4096 → Basic Auth → OpenCode:4096
```

## Consequences

### Pros
- Защита без OAuth/SAML
- Простая интеграция
- Web UI для управления

### Cons
- Дополнительный контейнер
- Basic Auth — не самый безопасный вариант

### Mitigation
Для чувствительных данных клиент может настроить свой OAuth.

---

## ADR-008: Git-based Backup Strategy

## Status
Accepted

## Context
Документ определяет "backup через git" — клиент сам коммитит изменения.

## Decision
**Клиент управляет бэкапами через git:**

1. OpenCode настроен с git integration
2. Агенты автоматически коммитят в репозиторий
3. Клиент пушит на GitHub/GitLab

### What's NOT included:
- Автоматические бэкапы
- Scheduled commits
- Backup ротация

### Rationale:
- Git — естественный инструмент для кода
- GitHub — бесплатный hosting
- Клиент контролирует свои данные

## Consequences

### Pros
- Простая модель
- Бесплатно
- История изменений

### Cons
- Требует понимания git
- Не подходит для бинарных данных
- Клиент может забыть запушить

### Mitigation
Агенты напоминают о коммитах через периодические напоминания.

---

## ADR-009: Directory Structure for Agents

## Status
Accepted

## Context
144 агента из agency-agents нужно организовать в структуру.

## Decision
**Структура по divisions:**

```
configs/agents/
├── engineering/           # 30+ agents
│   ├── engineering-backend-architect.md
│   ├── engineering-frontend-developer.md
│   ├── engineering-devops-automator.md
│   ├── engineering-software-architect.md
│   ├── engineering-technical-writer.md
│   └── ...
├── design/               # 8 agents
├── paid-media/           # 7 agents
├── sales/               # 9 agents
├── marketing/           # 27 agents
├── product/             # 5 agents
├── project-management/   # 6 agents
├── testing/             # 8 agents
├── support/             # 7 agents
├── specialized/         # 30+ agents
│   ├── specialized-workflow-architect.md
│   └── ...
├── finance/             # 5 agents
└── game-development/    # 20+ agents
```

## Consequences

### Pros
- Логичная группировка
- Легко найти нужного агента
- Соответствует оригинальной структуре agency-agents

### Cons
- Глубокая вложенность
- Некоторые агенты могут принадлежать нескольким категориям

---

## ADR-010: Skills Structure

## Status
Accepted

## Context
Скиллы — ключевой компонент для работы агентов. Нужна структура.

## Decision
**Структура скиллов:**

```
configs/skills/
├── olore-opencode-latest/    # Документация OpenCode
│   ├── SKILL.md
│   ├── TOC.md
│   └── contents/
├── agent-memory/             # Запоминание контекста
├── opencode-agent-skills/    # Динамическая загрузка
├── opencode-skill-generator/ # Генерация конфигов
│   └── references/
│       └── schema.json      # opencode.json schema
└── mcp-finder/              # Поиск MCP серверов
```

## Consequences

### Pros
- Стандартная структура OpenCode
- Легко добавлять новые скиллы
- olore автоматически обновляет документацию

### Cons
- schema.json нужен отдельно для skill-generator
