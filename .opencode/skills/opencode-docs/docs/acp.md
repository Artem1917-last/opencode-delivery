ACP Support | OpenCode

On this page

-   [Overview](#_top)
-   [Configure](#configure)
-   [Support](#support)

# ACP Support

Use OpenCode in any ACP-compatible editor.

OpenCode supports the [Agent Client Protocol](https://agentclientprotocol.com) or (ACP), allowing you to use it directly in compatible editors and IDEs.

ACP is an open protocol that standardizes communication between code editors and AI coding agents.

---

## [Configure](#configure)

To use OpenCode via ACP, configure your editor to run the `opencode acp` command.

### [Zed](#zed)

Add to your Zed configuration (`~/.config/zed/settings.json`):

```
{  "agent_servers": {    "OpenCode": {      "command": "opencode",      "args": ["acp"]    }  }}
```

### [JetBrains IDEs](#jetbrains-ides)

Add to your acp.json:

```
{  "agent_servers": {    "OpenCode": {      "command": "/absolute/path/bin/opencode",      "args": ["acp"]    }  }}
```

### [Avante.nvim](#avantenvim)

```
{  acp_providers = {    ["opencode"] = {      command = "opencode",      args = { "acp" }    }  }}
```

### [CodeCompanion.nvim](#codecompanionnvim)

```
require("codecompanion").setup({  interactions = {    chat = {      adapter = {        name = "opencode",        model = "claude-sonnet-4",      },    },  },})
```

---

## [Support](#support)

OpenCode works the same via ACP as it does in the terminal. All features are supported:

-   Built-in tools (file operations, terminal commands, etc.)
-   Custom tools and slash commands
-   MCP servers configured in your OpenCode config
-   Project-specific rules from `AGENTS.md`
-   Custom formatters and linters
-   Agents and permissions system

Note

Some built-in slash commands like `/undo` and `/redo` are currently unsupported.

Last updated: Apr 27, 2026
