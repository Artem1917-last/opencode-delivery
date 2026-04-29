---
name: opencode-docs
description: Полная официальная документация OpenCode — установка, конфиги, агенты, инструменты, MCP, CLI, TUI, SDK, сервер, провайдеры, плагины, скиллы, правила, темы, хоткеи, разрешения, кастомные инструменты, ACP, GitHub/GitLab интеграции
tags: [documentation, opencode, config, agents, tools, mcp, cli, tui, sdk, server, providers, plugins, skills, rules, themes, keybinds, permissions]
---

# OpenCode — Полная документация

Официальная документация OpenCode (скачана с opencode.ai/docs). Все страницы сохранены в `docs/` директории этого скилла.

## Как использовать

Когда пользователь спрашивает про OpenCode, читай соответствующий файл из `docs/` директории этого скилла с помощью Read tool.

## Структура документации

### Введение
- **Intro** — `docs/intro.md` — установка, настройка, инициализация (/init), использование
- **Troubleshooting** — `docs/troubleshooting.md` — логи, хранилище, десктоп, WebView2, WSL, ProviderInitError, AI_APICallError
- **Enterprise** — `docs/enterprise.md` — enterprise фичи
- **Network** — `docs/network.md` — прокси, HTTPS_PROXY, HTTP_PROXY, NO_PROXY
- **Windows WSL** — `docs/windows-wsl.md` — установка и настройка на Windows через WSL

### Использование (Usage)
- **TUI** — `docs/tui.md` — терминальный интерфейс, @файлы, !bash, /команды
- **CLI** — `docs/cli.md` — все CLI команды
- **Web** — `docs/web.md` — веб-интерфейс, opencode web
- **IDE** — `docs/ide.md` — VS Code, Cursor, Windsurf, VSCodium
- **Go** — `docs/go.md` — подписка $5/мес, открытые модели
- **Zen** — `docs/zen.md` — AI gateway, pay-as-you-go
- **Share** — `docs/share.md` — /share, /unshare, режимы
- **GitHub** — `docs/github.md` — /opencode в issues/PR, GitHub Actions
- **GitLab** — `docs/gitlab.md` — GitLab CI компонент, @opencode в MR/issues

### Конфигурация (Configure)
- **Config** — `docs/config.md` — opencode.json, tui.json, precedence
- **Providers** — `docs/providers.md` — 75+ провайдеров, API ключи
- **Models** — `docs/models.md` — provider/model формат, small_model, variants
- **Agents** — `docs/agents.md` — primary и subagent, конфиг
- **Rules** — `docs/rules.md` — AGENTS.md, CLAUDE.md совместимость
- **Tools** — `docs/tools.md` — built-in инструменты, permissions
- **Permissions** — `docs/permissions.md` — гранулярные правила, wildcard
- **MCP Servers** — `docs/mcp-servers.md` — local и remote MCP, OAuth
- **Skills** — `docs/skills.md` — .opencode/skills/<name>/SKILL.md
- **Custom Tools** — `docs/custom-tools.md` — TypeScript/JS в .opencode/tools/
- **Commands** — `docs/commands.md` — кастомные /команды
- **Keybinds** — `docs/keybinds.md` — tui.json, leader key
- **Themes** — `docs/themes.md` — встроенные и кастомные темы
- **Formatters** — `docs/formatters.md` — auto-detect и кастомные
- **LSP Servers** — `docs/lsp.md` — auto-detect и кастомные
- **ACP Support** — `docs/acp.md` — Agent Client Protocol

### Разработка (Develop)
- **SDK** — `docs/sdk.md` — npm @opencode-ai/sdk, API
- **Server** — `docs/server.md` — opencode serve, OpenAPI
- **Plugins** — `docs/plugins.md` — хуки, .opencode/plugins/
- **Ecosystem** — `docs/ecosystem.md` — community plugins, projects, agents

## Обновление документации

```bash
olore update opencode
```
