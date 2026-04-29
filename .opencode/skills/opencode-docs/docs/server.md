Server | OpenCode

On this page

-   [Overview](#_top)
-   [Spec](#spec)
-   [APIs](#apis)

# Server

Interact with opencode server over HTTP.

The `opencode serve` command runs a headless HTTP server that exposes an OpenAPI endpoint.

---

### [Usage](#usage)

Terminal window

```
opencode serve [--port <number>] [--hostname <string>] [--cors <origin>]
```

#### [Options](#options)

| Flag | Description | Default |
|------|-------------|---------|
| `--port` | Port to listen on | `4096` |
| `--hostname` | Hostname to listen on | `127.0.0.1` |
| `--mdns` | Enable mDNS discovery | `false` |
| `--mdns-domain` | Custom mDNS domain | `opencode.local` |
| `--cors` | Additional browser origins | `[]` |

---

### [Authentication](#authentication)

Set `OPENCODE_SERVER_PASSWORD` to protect the server with HTTP basic auth:

```
OPENCODE_SERVER_PASSWORD=your-password opencode serve
```

The username defaults to `opencode`, or set `OPENCODE_SERVER_USERNAME` to override.

---

### [How it works](#how-it-works)

When you run `opencode` it starts a TUI and a server. The server exposes an OpenAPI 3.1 spec endpoint.

This architecture lets opencode support multiple clients and allows you to interact with opencode programmatically.

---

## [Spec](#spec)

The server publishes an OpenAPI 3.1 spec at:

```
http://<hostname>:<port>/doc
```

---

## [APIs](#apis)

### [Global](#global)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/global/health` | Get server health and version |
| `GET` | `/global/event` | Get global events (SSE) |

### [Project](#project)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/project` | List all projects |
| `GET` | `/project/current` | Get current project |

### [Sessions](#sessions)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/session` | List all sessions |
| `POST` | `/session` | Create a new session |
| `GET` | `/session/:id` | Get session details |
| `DELETE` | `/session/:id` | Delete a session |
| `POST` | `/session/:id/prompt_async` | Send a message |
| `POST` | `/session/:id/command` | Execute a slash command |
| `POST` | `/session/:id/shell` | Run a shell command |
| `POST` | `/session/:id/share` | Share a session |
| `GET` | `/session/:id/message` | List messages |

### [Files](#files)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/find?pattern=<pat>` | Search for text |
| `GET` | `/find/file?query=<q>` | Find files |
| `GET` | `/file/content?path=<p>` | Read a file |
| `GET` | `/file/status` | Get file status |

### [Agents](#agents)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/agent` | List all available agents |

### [Events](#events)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/event` | Server-sent events stream |

### [TUI](#tui)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/tui/append-prompt` | Append text to prompt |
| `POST` | `/tui/submit-prompt` | Submit the current prompt |
| `POST` | `/tui/execute-command` | Execute a command |
| `POST` | `/tui/show-toast` | Show toast notification |

### [Auth](#auth)

| Method | Path | Description |
|--------|------|-------------|
| `PUT` | `/auth/:id` | Set authentication credentials |

### [Docs](#docs)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/doc` | OpenAPI 3.1 specification |

Last updated: Apr 27, 2026
