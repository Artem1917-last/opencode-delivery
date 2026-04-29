Plugins | OpenCode

On this page

-   [Overview](#_top)
-   [Use a plugin](#use-a-plugin)
-   [Create a plugin](#create-a-plugin)
-   [Examples](#examples)

# Plugins

Write your own plugins to extend OpenCode.

Plugins allow you to extend OpenCode by hooking into various events and customizing behavior.

---

## [Use a plugin](#use-a-plugin)

### [From local files](#from-local-files)

Place JavaScript or TypeScript files in:

-   `.opencode/plugins/` - Project-level
-   `~/.config/opencode/plugins/` - Global

### [From npm](#from-npm)

Specify npm packages in your config:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "plugin": ["opencode-helicone-session", "opencode-wakatime"]}
```

### [Load order](#load-order)

1.  Global config
2.  Project config
3.  Global plugin directory
4.  Project plugin directory

---

## [Create a plugin](#create-a-plugin)

A plugin is a **JavaScript/TypeScript module** that exports plugin functions.

### [Basic structure](#basic-structure)

.opencode/plugins/example.js

```
export const MyPlugin = async ({ project, client, $, directory, worktree }) => {  console.log("Plugin initialized!")
  return {    // Hook implementations  }}
```

The plugin function receives:

-   `project`: Current project information
-   `directory`: Current working directory
-   `worktree`: Git worktree path
-   `client`: OpenCode SDK client
-   `$`: Bun's shell API

### [TypeScript support](#typescript-support)

```
import type { Plugin } from "@opencode-ai/plugin"

export const MyPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {  return {    // Type-safe hook implementations  }}
```

### [Events](#events)

Plugins can subscribe to events:

-   **Session**: `session.created`, `session.idle`, `session.deleted`, `session.compacted`
-   **Message**: `message.updated`, `message.removed`, `message.part.updated`
-   **File**: `file.edited`, `file.watcher.updated`
-   **Tool**: `tool.execute.before`, `tool.execute.after`
-   **Permission**: `permission.asked`, `permission.replied`
-   **TUI**: `tui.prompt.append`, `tui.command.execute`, `tui.toast.show`
-   **Server**: `server.connected`
-   And more...

---

## [Examples](#examples)

### [Send notifications](#send-notifications)

```
export const NotificationPlugin = async ({ project, client, $ }) => {  return {    event: async ({ event }) => {      if (event.type === "session.idle") {        await $`osascript -e 'display notification "Session completed!" with title "opencode"'`      }    },  }}
```

### [.env protection](#env-protection)

```
export const EnvProtection = async () => {  return {    "tool.execute.before": async (input, output) => {      if (input.tool === "read" && output.args.filePath.includes(".env")) {        throw new Error("Do not read .env files")      }    },  }}
```

### [Inject environment variables](#inject-environment-variables)

```
export const InjectEnvPlugin = async () => {  return {    "shell.env": async (input, output) => {      output.env.MY_API_KEY = "secret"    },  }}
```

### [Custom tools](#custom-tools)

```
import { type Plugin, tool } from "@opencode-ai/plugin"

export const CustomToolsPlugin: Plugin = async (ctx) => {  return {    tool: {      mytool: tool({        description: "This is a custom tool",        args: {          foo: tool.schema.string(),        },        async execute(args, context) {          return `Hello ${args.foo}`        },      }),    },  }}
```

### [Logging](#logging)

```
export const MyPlugin = async ({ client }) => {  await client.app.log({    body: {      service: "my-plugin",      level: "info",      message: "Plugin initialized",    },  })}
```

### [Compaction hooks](#compaction-hooks)

```
import type { Plugin } from "@opencode-ai/plugin"

export const CompactionPlugin: Plugin = async (ctx) => {  return {    "experimental.session.compacting": async (input, output) => {      output.context.push("## Custom Context\nInclude any state that should persist.")    },  }}
```

Last updated: Apr 27, 2026
