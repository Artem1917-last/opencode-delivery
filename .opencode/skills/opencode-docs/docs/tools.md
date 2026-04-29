Tools | OpenCode

On this page

-   [Overview](#_top)
-   [Configure](#configure)
-   [Built-in](#built-in)
-   [Custom tools](#custom-tools)
-   [MCP servers](#mcp-servers)
-   [Internals](#internals)

# Tools

Manage the tools an LLM can use.

Tools allow the LLM to perform actions in your codebase. OpenCode comes with a set of built-in tools, but you can extend it with [custom tools](/docs/custom-tools) or [MCP servers](/docs/mcp-servers).

By default, all tools are **enabled** and don't need permission to run. You can control tool behavior through [permissions](/docs/permissions).

---

## [Configure](#configure)

Use the `permission` field to control tool behavior. You can allow, deny, or require approval for each tool.

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "permission": {    "edit": "deny",    "bash": "ask",    "webfetch": "allow"  }}
```

You can also use wildcards to control multiple tools at once.

---

## [Built-in](#built-in)

Here are all the built-in tools available in OpenCode.

---

### [bash](#bash)

Execute shell commands in your project environment.

---

### [edit](#edit)

Modify existing files using exact string replacements.

---

### [write](#write)

Create new files or overwrite existing ones.

Note

The `write` tool is controlled by the `edit` permission.

---

### [read](#read)

Read file contents from your codebase.

---

### [grep](#grep)

Search file contents using regular expressions.

---

### [glob](#glob)

Find files by pattern matching.

---

### [lsp (experimental)](#lsp-experimental)

Interact with your configured LSP servers to get code intelligence features like definitions, references, hover info, and call hierarchy.

Note

This tool is only available when `OPENCODE_EXPERIMENTAL_LSP_TOOL=true`.

---

### [apply_patch](#apply_patch)

Apply patches to files.

Note

The `apply_patch` tool is controlled by the `edit` permission.

---

### [skill](#skill)

Load a [skill](/docs/skills) (a `SKILL.md` file) and return its content in the conversation.

---

### [todowrite](#todowrite)

Manage todo lists during coding sessions.

---

### [webfetch](#webfetch)

Fetch web content.

---

### [websearch](#websearch)

Search the web for information.

Note

This tool is only available when using the OpenCode provider or when `OPENCODE_ENABLE_EXA` is set.

---

### [question](#question)

Ask the user questions during execution.

---

## [Custom tools](#custom-tools)

Custom tools let you define your own functions that the LLM can call. [Learn more](/docs/custom-tools).

---

## [MCP servers](#mcp-servers)

MCP (Model Context Protocol) servers allow you to integrate external tools and services. [Learn more](/docs/mcp-servers).

---

## [Internals](#internals)

Internally, tools like `grep` and `glob` use [ripgrep](https://github.com/BurntSushi/ripgrep) under the hood. By default, ripgrep respects `.gitignore` patterns.

---

### [Ignore patterns](#ignore-patterns)

To include files that would normally be ignored, create a `.ignore` file in your project root.

.ignore

```
!node_modules/
!dist/
!build/
```

Last updated: Apr 27, 2026
