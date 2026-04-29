---
name: opencode-docs
description: Полная официальная документация OpenCode — установка, конфиги, агенты, инструменты, MCP, CLI, TUI, SDK, сервер, провайдеры, плагины, скиллы, правила, темы, хоткеи, разрешения, кастомные инструменты, ACP, GitHub/GitLab интеграции
tags: [documentation, opencode, config, agents, tools, mcp, cli, tui, sdk, server, providers, plugins, skills, rules, themes, keybinds, permissions]
---

# OpenCode — Полная документация

Официальная документация OpenCode (скачана с opencode.ai/docs). Агент обращается к ней когда спрашиваешь "как настроить", "какие команды", "как добавить MCP" и т.д.

## Структура документации

### Введение
- **Intro** — установка, настройка, инициализация (/init), использование
- **Troubleshooting** — логи, хранилище, десктоп, WebView2, WSL, ProviderInitError, AI_APICallError

### Использование
- **TUI** — терминальный интерфейс, @файлы, !bash, /команды, /connect, /compact, /editor, /exit, /export, /help, /init, /models, /new, /redo, /sessions, /share, /themes, /thinking, /undo, /unshare
- **CLI** — opencode [project], opencode run "prompt", opencode serve, opencode web, opencode acp, opencode attach, opencode agent create/list, opencode auth login/list/logout, opencode github install/run, opencode mcp add/list/auth/logout/debug, opencode models, opencode session list, opencode export/import, opencode stats, opencode upgrade/uninstall
- **Web** — opencode web --port --hostname --mdns --cors, OPENCODE_SERVER_PASSWORD
- **IDE** — VS Code, Cursor, Windsurf, VSCodium; Cmd+Esc / Ctrl+Esc
- **Go** — подписка $5/мес, открытые модели (Qwen3.6 Plus, GLM-5, Kimi K2, DeepSeek V4, MiniMax M2)
- **Zen** — AI gateway, pay-as-you-go, модели (GPT 5.5, Claude Opus 4.7, Sonnet 4.6, Gemini 3.1 Pro, Qwen3.6 Plus)
- **Share** — /share, /unshare, режимы: manual/auto/disabled
- **GitHub** — /opencode в issues/PR, GitHub Actions, opencode github install
- **GitLab** — GitLab CI компонент, @opencode в MR/issues

### Конфигурация
- **Config** — opencode.json (JSON/JSONC), tui.json, precedence: remote → global → custom → project → .opencode dirs → inline → managed
- **Providers** — 75+ провайдеров: Anthropic, OpenAI, Google, Amazon Bedrock, Ollama, LM Studio, OpenRouter, Vercel AI Gateway, Helicone, Cloudflare, Groq, NVIDIA, Together AI, xAI, DeepSeek, и др. /connect для авторизации
- **Models** — provider/model формат, small_model, variants (high/low/none), opencode models --refresh
- **Agents** — primary (Build, Plan) и subagent (General, Explore), конфиг в opencode.json или .md файлы в .opencode/agents/ или ~/.config/opencode/agents/. Опции: description, model, temperature, steps, prompt, permission, mode, hidden, task permission, color, top_p
- **Rules** — AGENTS.md в project root, ~/.config/opencode/AGENTS.md для глобальных, CLAUDE.md совместимость, instructions в opencode.json
- **Tools** — built-in: bash, edit, write, read, grep, glob, lsp (experimental), apply_patch, skill, todowrite, webfetch, websearch, question. permission: allow/ask/deny
- **Permissions** — гранулярные правила с wildcard: "git *": "allow", "rm *": "deny". external_directory для путей вне проекта. doom_loop защита
- **MCP servers** — local (type: "local", command: [...]) и remote (type: "remote", url: "..."). OAuth автоматический. opencode mcp add
- **Skills** — .opencode/skills/<name>/SKILL.md, frontmatter: name, description. skill tool для загрузки. permissions: skill: {"*": "allow"}
- **Custom Tools** — TypeScript/JS файлы в .opencode/tools/, tool() helper с Zod schema, execute(args, context)
- **Commands** — кастомные /команды через .opencode/commands/*.md или opencode.json command. $ARGUMENTS, $1, $2, !`shell output`, @file
- **Keybinds** — tui.json, leader key (ctrl+x по умолчанию), "none" для отключения
- **Themes** — system, tokyonight, everforest, ayu, catppuccin, gruvbox, kanagawa, nord, matrix, one-dark. Кастомные JSON темы в .opencode/themes/
- **Formatters** — auto-detect: prettier, biome, gofmt, ruff, rustfmt, clang-format, black, shfmt и др. Кастомные через formatter config
- **LSP Servers** — auto-detect: typescript, pyright, gopls, rust-analyzer, deno, eslint, vue, svelte и др. Кастомные через lsp config
- **ACP Support** — Agent Client Protocol, opencode acp, интеграция с Zed, JetBrains, Avante.nvim, CodeCompanion.nvim
- **Network** — HTTPS_PROXY, HTTP_PROXY, NO_PROXY, NODE_EXTRA_CA_CERTS
- **Plugins** — .opencode/plugins/ или npm packages в opencode.json plugin массив. Хуки: tool.execute.before/after, session.created/idle, file.edited, message.updated, permission.asked, shell.env и др.
- **Server** — opencode serve --port --hostname --mdns --cors, OpenAPI spec на /doc, HTTP basic auth через OPENCODE_SERVER_PASSWORD
- **SDK** — npm install @opencode-ai/sdk, createOpencode(), client.session.prompt(), client.find.text(), client.event.subscribe()
- **Ecosystem** — community plugins, projects, agents

## Ключевые команды CLI

| Команда | Описание |
|---------|----------|
| `opencode` | Запуск TUI |
| `opencode run "prompt"` | Неразговорчивый режим |
| `opencode serve` | Headless HTTP сервер |
| `opencode web` | Веб-интерфейс |
| `opencode acp` | ACP сервер |
| `opencode attach http://host:port` | Подключить TUI к серверу |
| `opencode models` | Список доступных моделей |
| `opencode models --refresh` | Обновить кэш моделей |
| `opencode stats` | Статистика использования |
| `opencode agent create` | Интерактивное создание агента |
| `opencode mcp add` | Добавить MCP сервер |
| `opencode mcp list` | Список MCP серверов |
| `opencode auth login` | Авторизация провайдера |
| `opencode github install` | Установка GitHub интеграции |
| `opencode upgrade` | Обновление до последней версии |
| `opencode uninstall` | Удаление OpenCode |

## Структура конфигов

### opencode.json (сервер/рантайм)
```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5",
  "provider": {},
  "agent": {},
  "command": {},
  "mcp": {},
  "plugin": [],
  "permission": {},
  "formatter": {},
  "lsp": {},
  "tools": {},
  "instructions": [],
  "share": "manual",
  "autoupdate": true,
  "snapshot": true,
  "server": { "port": 4096, "hostname": "0.0.0.0" },
  "watcher": { "ignore": ["node_modules/**"] },
  "compaction": { "auto": true, "prune": true },
  "disabled_providers": [],
  "enabled_providers": []
}
```

### tui.json (интерфейс)
```json
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "tokyonight",
  "keybinds": { "leader": "ctrl+x" },
  "scroll_speed": 3,
  "diff_style": "auto",
  "mouse": true
}
```

## Переменные окружения

| Переменная | Описание |
|------------|----------|
| `OPENCODE_SERVER_PASSWORD` | Basic auth для serve/web |
| `OPENCODE_SERVER_USERNAME` | Override username (default: opencode) |
| `OPENCODE_CONFIG` | Путь к кастомному конфиг файлу |
| `OPENCODE_CONFIG_DIR` | Путь к кастомной директории конфигов |
| `OPENCODE_CONFIG_CONTENT` | Inline JSON конфиг |
| `OPENCODE_TUI_CONFIG` | Путь к кастомному tui.json |
| `OPENCODE_AUTO_SHARE` | Авто-шеринг сессий |
| `OPENCODE_DISABLE_AUTOUPDATE` | Отключить автообновление |
| `OPENCODE_DISABLE_LSP_DOWNLOAD` | Отключить автозагрузку LSP |
| `OPENCODE_DISABLE_CLAUDE_CODE` | Отключить .claude совместимость |
| `OPENCODE_ENABLE_EXA` | Включить websearch |
| `OPENCODE_EXPERIMENTAL` | Включить все экспериментальные фичи |
| `OPENCODE_EXPERIMENTAL_LSP_TOOL` | Включить LSP tool |
| `OPENCODE_PERMISSION` | Inline JSON permissions |
| `OPENCODE_MODELS_URL` | Кастомный URL для моделей |
| `OPENCODE_GIT_BASH_PATH` | Путь к Git Bash на Windows |
| `OPENCODE_CLIENT` | Client identifier (default: cli) |

## Расположение файлов

| Тип | Глобальный | Проектный |
|-----|-----------|-----------|
| Конфиг | ~/.config/opencode/opencode.json | opencode.json |
| TUI конфиг | ~/.config/opencode/tui.json | tui.json |
| Агенты | ~/.config/opencode/agents/ | .opencode/agents/ |
| Команды | ~/.config/opencode/commands/ | .opencode/commands/ |
| Скиллы | ~/.config/opencode/skills/ | .opencode/skills/ |
| Плагины | ~/.config/opencode/plugins/ | .opencode/plugins/ |
| Темы | ~/.config/opencode/themes/ | .opencode/themes/ |
| Инструменты | ~/.config/opencode/tools/ | .opencode/tools/ |
| Правила | ~/.config/opencode/AGENTS.md | AGENTS.md |
| Auth | ~/.local/share/opencode/auth.json | — |
| Логи | ~/.local/share/opencode/log/ | — |
| Сессии | ~/.local/share/opencode/project/ | ./storage/ |

## Обновление документации

```bash
olore update opencode
```
