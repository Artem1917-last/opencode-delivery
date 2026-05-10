# Планируемые компоненты OpenCode

## MCP Серверы

| Название | Команда | Назначение |
|----------|---------|------------|
| filesystem | `npx @modelcontextprotocol/server-filesystem /home/devuser` | Доступ к файлам сервера |
| github | `npx @modelcontextprotocol/server-github` | Интеграция с GitHub |
| playwright | `npx @modelcontextprotocol/server-playwright` | Браузерная автоматизация |
| mcp-finder | `npx mcp-finder` | Поиск MCP серверов |
| mcp-discovery | `npx mcp-server-discovery` | Обнаружение MCP серверов |
| mcp-compass | `npx mcp-compass` | Рекомендации MCP |
| google-workspace | `python3 -m google_workspace_mcp` | Gmail, Calendar, Drive, Docs |
| telegram | `python3 -m telegram_mcp` | Telegram |
| local-rag | `npx mcp-local-rag --path /home/devuser/rag-data` | Локальный RAG |
| code-sandbox | `npx node-code-sandbox-mcp` | Безопасный запуск кода |

## Плагины

| Название | npm пакет | Назначение |
|----------|-----------|------------|
| agent-memory | `@opencode/agent-memory` | Память агентов между сессиями |
| planner | `@plannotator/opencode` | Планирование задач |
| subtask2 | `@openspoon/subtask2` | Декомпозиция задач |
| antigravity-auth | `@opencode/antigravity-auth` | Бесплатный AI провайдер |
| gemini-auth | `@opencode/gemini-auth` | Google Gemini провайдер |

## Скиллы

| Название | Описание |
|----------|----------|
| agent-memory | Запоминание контекста между сессиями |
| mcp-finder | Поиск MCP серверов (6,700+ индексировано) |
| olore-opencode-latest | Локальная документация OpenCode |
| opencode-skill-generator | Генерация конфигов OpenCode |
