MCP servers | OpenCode

On this page

-   [Overview](#_top)
-   [Enable](#enable)
-   [Local](#local)
-   [Remote](#remote)
-   [OAuth](#oauth)
-   [Manage](#manage)
-   [Examples](#examples)

# MCP servers

Add local and remote MCP tools.

You can add external tools to OpenCode using the *Model Context Protocol*, or MCP. OpenCode supports both local and remote servers.

---

## [Enable](#enable)

Define MCP servers in your config under `mcp`:

opencode.jsonc

```
{  "$schema": "https://opencode.ai/config.json",  "mcp": {    "name-of-mcp-server": {      "enabled": true    }  }}
```

---

## [Local](#local)

Add local MCP servers using `type: "local"`:

opencode.jsonc

```
{  "$schema": "https://opencode.ai/config.json",  "mcp": {    "my-local-mcp": {      "type": "local",      "command": ["npx", "-y", "my-mcp-command"],      "environment": {        "MY_ENV_VAR": "value"      }    }  }}
```

### [Options](#options)

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `type` | String | Y | Must be `"local"` |
| `command` | Array | Y | Command and arguments |
| `environment` | Object | | Environment variables |
| `enabled` | Boolean | | Enable/disable on startup |
| `timeout` | Number | | Timeout in ms (default: 5000) |

---

## [Remote](#remote)

Add remote MCP servers using `type: "remote"`:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "mcp": {    "my-remote-mcp": {      "type": "remote",      "url": "https://my-mcp-server.com",      "headers": {        "Authorization": "Bearer MY_API_KEY"      }    }  }}
```

### [Options](#options-1)

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `type` | String | Y | Must be `"remote"` |
| `url` | String | Y | URL of the remote MCP server |
| `enabled` | Boolean | | Enable/disable on startup |
| `headers` | Object | | Headers to send |
| `oauth` | Object | | OAuth configuration |
| `timeout` | Number | | Timeout in ms (default: 5000) |

---

## [OAuth](#oauth)

OpenCode automatically handles OAuth authentication for remote MCP servers.

### [Automatic](#automatic)

For most OAuth-enabled MCP servers, no special configuration is needed. OpenCode will prompt you to authenticate when you first try to use it.

### [Pre-registered](#pre-registered)

If you have client credentials:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "mcp": {    "my-oauth-server": {      "type": "remote",      "url": "https://mcp.example.com/mcp",      "oauth": {        "clientId": "{env:MY_CLIENT_ID}",        "clientSecret": "{env:MY_CLIENT_SECRET}",        "scope": "tools:read tools:execute"      }    }  }}
```

### [Authenticating](#authenticating)

```
# Authenticate with a specific MCP server
opencode mcp auth my-oauth-server

# List all MCP servers and their auth status
opencode mcp list

# Remove stored credentials
opencode mcp logout my-oauth-server
```

---

## [Manage](#manage)

### [Global](#global)

Disable MCP tools globally:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "tools": {    "my-mcp*": false  }}
```

### [Per agent](#per-agent)

Enable MCP per agent:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "tools": {    "my-mcp*": false  },  "agent": {    "my-agent": {      "tools": {        "my-mcp*": true      }    }  }}
```

---

## [Examples](#examples)

### [Sentry](#sentry)

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "mcp": {    "sentry": {      "type": "remote",      "url": "https://mcp.sentry.dev/mcp",      "oauth": {}    }  }}
```

Authenticate:

```
opencode mcp auth sentry
```

### [Context7](#context7)

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "mcp": {    "context7": {      "type": "remote",      "url": "https://mcp.context7.com/mcp"    }  }}
```

### [Grep by Vercel](#grep-by-vercel)

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "mcp": {    "gh_grep": {      "type": "remote",      "url": "https://mcp.grep.app"    }  }}
```

Last updated: Apr 27, 2026
