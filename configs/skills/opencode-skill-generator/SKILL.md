---
name: opencode-skill-generator
description: Генерация конфигов OpenCode (agents, commands, MCP, plugins)
tags: [config, generator, opencode-json]
---

# opencode-skill-generator

Генерация валидных конфигов OpenCode на основе JSON schema.

## Что генерирует

| Компонент | Что генерирует |
|-----------|----------------|
| Supagent | Agent конфиг в opencode.json |
| Command | Slash commands |
| MCP | Local/Remote MCP серверы |
| Frontmatter | YAML frontmatter для скиллов |
| Plugin | Список плагинов |
| Agent Skill | Структура папок для скиллов |
| Tool | Конфигурация инструментов |

## Использование

Агент использует этот скилл для создания конфигураций. Ссылается на `references/schema.json` для валидации.

## Важно

- Скилл генерирует конфиги на основе JSON schema
- Для корректной работы нужен файл `references/schema.json`
- Агент использует схему для валидации генерируемых конфигов
