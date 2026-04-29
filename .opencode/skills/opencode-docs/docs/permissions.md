Permissions | OpenCode

On this page

-   [Overview](#_top)
-   [Actions](#actions)
-   [Configuration](#configuration)
-   [Granular Rules](#granular-rules-object-syntax)
-   [Available Permissions](#available-permissions)
-   [Defaults](#defaults)
-   [Agents](#agents)

# Permissions

Control which actions require approval to run.

OpenCode uses the `permission` config to decide whether a given action should run automatically, prompt you, or be blocked.

---

## [Actions](#actions)

Each permission rule resolves to one of:

-   `"allow"` — run without approval
-   `"ask"` — prompt for approval
-   `"deny"` — block the action

---

## [Configuration](#configuration)

You can set permissions globally and override specific tools:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "permission": {    "*": "ask",    "bash": "allow",    "edit": "deny"  }}
```

You can also set all permissions at once:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "permission": "allow"}
```

---

## [Granular Rules (Object Syntax)](#granular-rules-object-syntax)

For most permissions, you can use an object to apply different actions based on the tool input:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "permission": {    "bash": {      "*": "ask",      "git *": "allow",      "npm *": "allow",      "rm *": "deny"    },    "edit": {      "*": "deny",      "packages/web/src/*.mdx": "allow"    }  }}
```

Rules are evaluated by pattern match, with the **last matching rule winning**.

### [Wildcards](#wildcards)

-   `*` matches zero or more of any character
-   `?` matches exactly one character

### [Home Directory Expansion](#home-directory-expansion)

Use `~` or `$HOME` at the start of a pattern:

-   `~/projects/*` -> `/Users/username/projects/*`

### [External Directories](#external-directories)

Use `external_directory` to allow tool calls that touch paths outside the working directory:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "permission": {    "external_directory": {      "~/projects/personal/**": "allow"    }  }}
```

---

## [Available Permissions](#available-permissions)

-   `read` — reading a file
-   `edit` — all file modifications (covers `edit`, `write`, `patch`)
-   `glob` — file globbing
-   `grep` — content search
-   `bash` — running shell commands
-   `task` — launching subagents
-   `skill` — loading a skill
-   `lsp` — running LSP queries
-   `question` — asking the user questions
-   `webfetch` — fetching a URL
-   `websearch`, `codesearch` — web/code search
-   `external_directory` — paths outside the working directory
-   `doom_loop` — triggered when the same tool call repeats 3 times

---

## [Defaults](#defaults)

-   Most permissions default to `"allow"`.
-   `doom_loop` and `external_directory` default to `"ask"`.
-   `read` is `"allow"`, but `.env` files are denied by default.

---

## [What "Ask" Does](#what-ask-does)

When OpenCode prompts for approval:

-   `once` — approve just this request
-   `always` — approve future requests matching the pattern
-   `reject` — deny the request

---

## [Agents](#agents)

You can override permissions per agent. Agent permissions are merged with the global config, and agent rules take precedence.

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "agent": {    "build": {      "permission": {        "bash": {          "*": "ask",          "git *": "allow"        }      }    }  }}
```

Last updated: Apr 27, 2026
