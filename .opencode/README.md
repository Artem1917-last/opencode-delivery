# OpenCode Dev Tool

Локальный OpenCode для разработки и "причёсывания" репозитория.

## Использование

```powershell
# Скачать OpenCode для Windows: https://opencode.ai/api/download/windows

# Запуск с локальным конфигом
opencode --config ./opencode/opencode-dev.json

# Проверить что агенты подхватились
opencode --config ./opencode/opencode-dev.json agents list
```

## Структура

- `opencode-dev.json` — локальный конфиг (НЕ symlink!)
- `.gitignore` — игнорировать локальные данные

## Конфиг

```json
{
  "agents_path": "./configs/agents",
  "skills_path": "./configs/skills",
  "workspace_path": "./",
  "storage_path": "./.opencode_local_data",
  "mcp_servers_path": "./configs/mcp"
}
```

## Примеры задач

- "Проверь архитектуру репозитория, предложи улучшения"
- "Сгенерируй документацию для клиента"
- "Проверь что все ADRs актуальны"
- "Найди мёртвые ссылки в README"