SDK | OpenCode

On this page

-   [Overview](#_top)
-   [Install](#install)
-   [Create client](#create-client)
-   [Config](#config)
-   [Client only](#client-only)
-   [Structured Output](#structured-output)
-   [APIs](#apis)

# SDK

Type-safe JS client for opencode server.

The opencode JS/TS SDK provides a type-safe client for interacting with the server.

---

## [Install](#install)

```
npm install @opencode-ai/sdk
```

---

## [Create client](#create-client)

```
import { createOpencode } from "@opencode-ai/sdk"

const { client } = await createOpencode()
```

This starts both a server and a client.

#### [Options](#options)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hostname` | `string` | `127.0.0.1` | Server hostname |
| `port` | `number` | `4096` | Server port |
| `signal` | `AbortSignal` | | Abort signal |
| `timeout` | `number` | `5000` | Timeout in ms |
| `config` | `Config` | `{}` | Configuration object |

---

## [Config](#config)

```
import { createOpencode } from "@opencode-ai/sdk"

const opencode = await createOpencode({  hostname: "127.0.0.1",  port: 4096,  config: {    model: "anthropic/claude-3-5-sonnet-20241022",  },})
```

---

## [Client only](#client-only)

If you already have a running server:

```
import { createOpencodeClient } from "@opencode-ai/sdk"

const client = createOpencodeClient({  baseUrl: "http://localhost:4096",})
```

---

## [Structured Output](#structured-output)

Request structured JSON output from the model:

```
const result = await client.session.prompt({  path: { id: sessionId },  body: {    parts: [{ type: "text", text: "Research Anthropic" }],    format: {      type: "json_schema",      schema: {        type: "object",        properties: {          company: { type: "string" },          founded: { type: "number" },        },        required: ["company", "founded"],      },    },  },})
```

---

## [APIs](#apis)

### [Global](#global)

-   `global.health()` - Check server health

### [Sessions](#sessions)

-   `session.list()` - List sessions
-   `session.get({ path })` - Get session
-   `session.create({ body })` - Create session
-   `session.delete({ path })` - Delete session
-   `session.prompt({ path, body })` - Send prompt
-   `session.command({ path, body })` - Execute command
-   `session.shell({ path, body })` - Run shell command
-   `session.share({ path })` - Share session
-   `session.messages({ path })` - List messages

### [Files](#files)

-   `find.text({ query })` - Search for text
-   `find.files({ query })` - Find files
-   `file.read({ query })` - Read a file

### [Events](#events)

-   `event.subscribe()` - Server-sent events stream

Last updated: Apr 27, 2026
