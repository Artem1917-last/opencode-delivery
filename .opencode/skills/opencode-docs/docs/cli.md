CLI | OpenCode

On this page

-   [Overview](#_top)
-   [Commands](#commands)
-   [Global Flags](#global-flags)
-   [Environment variables](#environment-variables)

# CLI

OpenCode CLI options and commands.

The OpenCode CLI by default starts the [TUI](/docs/tui) when run without any arguments.

Terminal window

```
opencode
```

But it also accepts commands as documented on this page.

---

### [tui](#tui)

Start the OpenCode terminal user interface.

Terminal window

```
opencode [project]
```

#### [Flags](#flags)

| Flag | Short | Description |
|------|-------|-------------|
| `--continue` | `-c` | Continue the last session |
| `--session` | `-s` | Session ID to continue |
| `--fork` | | Fork the session when continuing |
| `--prompt` | | Prompt to use |
| `--model` | `-m` | Model to use in the form of provider/model |
| `--agent` | | Agent to use |
| `--port` | | Port to listen on |
| `--hostname` | | Hostname to listen on |

---

## [Commands](#commands)

### [agent](#agent)

Manage agents for OpenCode.

Terminal window

```
opencode agent [command]
```

-   `opencode agent create` - Create a new agent with custom configuration
-   `opencode agent list` - List all available agents

### [auth](#auth)

Command to manage credentials and login for providers.

Terminal window

```
opencode auth [command]
```

-   `opencode auth login` - Configure API keys for providers
-   `opencode auth list` (or `ls`) - Lists all authenticated providers
-   `opencode auth logout` - Logs you out of a provider

### [github](#github)

Manage the GitHub agent for repository automation.

Terminal window

```
opencode github [command]
```

-   `opencode github install` - Install the GitHub agent in your repository
-   `opencode github run` - Run the GitHub agent

### [mcp](#mcp)

Manage Model Context Protocol servers.

Terminal window

```
opencode mcp [command]
```

-   `opencode mcp add` - Add an MCP server to your configuration
-   `opencode mcp list` (or `ls`) - List all configured MCP servers
-   `opencode mcp auth [name]` - Authenticate with an OAuth-enabled MCP server
-   `opencode mcp logout [name]` - Remove OAuth credentials
-   `opencode mcp debug <name>` - Debug OAuth connection issues

### [models](#models)

List all available models from configured providers.

Terminal window

```
opencode models [provider]
```

#### [Flags](#flags)

| Flag | Description |
|------|-------------|
| `--refresh` | Refresh the models cache from models.dev |
| `--verbose` | Use more verbose model output |

### [run](#run)

Run opencode in non-interactive mode by passing a prompt directly.

Terminal window

```
opencode run [message..]
```

#### [Flags](#flags)

| Flag | Short | Description |
|------|-------|-------------|
| `--command` | | The command to run |
| `--continue` | `-c` | Continue the last session |
| `--session` | `-s` | Session ID to continue |
| `--fork` | | Fork the session |
| `--share` | | Share the session |
| `--model` | `-m` | Model to use |
| `--agent` | | Agent to use |
| `--file` | `-f` | File(s) to attach to message |
| `--format` | | Format: default or json |
| `--title` | | Title for the session |
| `--attach` | | Attach to a running opencode server |
| `--port` | | Port for the local server |
| `--dangerously-skip-permissions` | | Auto-approve permissions |

### [serve](#serve)

Start a headless OpenCode server for API access.

Terminal window

```
opencode serve
```

#### [Flags](#flags)

| Flag | Description |
|------|-------------|
| `--port` | Port to listen on |
| `--hostname` | Hostname to listen on |
| `--mdns` | Enable mDNS discovery |
| `--cors` | Additional browser origin(s) to allow CORS |

### [session](#session)

Manage OpenCode sessions.

-   `opencode session list` - List all OpenCode sessions

### [stats](#stats)

Show token usage and cost statistics for your OpenCode sessions.

Terminal window

```
opencode stats
```

#### [Flags](#flags)

| Flag | Description |
|------|-------------|
| `--days` | Show stats for the last N days |
| `--tools` | Number of tools to show |
| `--models` | Show model usage breakdown |
| `--project` | Filter by project |

### [export](#export)

Export session data as JSON.

Terminal window

```
opencode export [sessionID]
```

### [import](#import)

Import session data from a JSON file or OpenCode share URL.

Terminal window

```
opencode import <file>
```

### [web](#web)

Start a headless OpenCode server with a web interface.

Terminal window

```
opencode web
```

#### [Flags](#flags)

| Flag | Description |
|------|-------------|
| `--port` | Port to listen on |
| `--hostname` | Hostname to listen on |
| `--mdns` | Enable mDNS discovery |
| `--cors` | Additional browser origin(s) to allow CORS |

### [acp](#acp)

Start an ACP (Agent Client Protocol) server.

Terminal window

```
opencode acp
```

### [uninstall](#uninstall)

Uninstall OpenCode and remove all related files.

Terminal window

```
opencode uninstall
```

#### [Flags](#flags)

| Flag | Short | Description |
|------|-------|-------------|
| `--keep-config` | `-c` | Keep configuration files |
| `--keep-data` | `-d` | Keep session data and snapshots |
| `--dry-run` | | Show what would be removed |
| `--force` | `-f` | Skip confirmation prompts |

### [upgrade](#upgrade)

Updates opencode to the latest version or a specific version.

Terminal window

```
opencode upgrade [target]
```

---

## [Global Flags](#global-flags)

| Flag | Short | Description |
|------|-------|-------------|
| `--help` | `-h` | Display help |
| `--version` | `-v` | Print version number |
| `--print-logs` | | Print logs to stderr |
| `--log-level` | | Log level (DEBUG, INFO, WARN, ERROR) |

---

## [Environment variables](#environment-variables)

| Variable | Type | Description |
|----------|------|-------------|
| `OPENCODE_AUTO_SHARE` | boolean | Automatically share sessions |
| `OPENCODE_CONFIG` | string | Path to config file |
| `OPENCODE_TUI_CONFIG` | string | Path to TUI config file |
| `OPENCODE_CONFIG_DIR` | string | Path to config directory |
| `OPENCODE_CONFIG_CONTENT` | string | Inline json config content |
| `OPENCODE_SERVER_PASSWORD` | string | Enable basic auth for `serve`/`web` |
| `OPENCODE_SERVER_USERNAME` | string | Override basic auth username |
| `OPENCODE_DISABLE_AUTOUPDATE` | boolean | Disable automatic update checks |
| `OPENCODE_ENABLE_EXA` | boolean | Enable Exa web search tools |
| `OPENCODE_DISABLE_LSP_DOWNLOAD` | boolean | Disable automatic LSP server downloads |

Last updated: Apr 27, 2026
