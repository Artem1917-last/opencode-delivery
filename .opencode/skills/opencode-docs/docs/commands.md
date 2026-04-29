Commands | OpenCode

On this page

-   [Overview](#_top)
-   [Create command files](#create-command-files)
-   [Configure](#configure)
-   [Prompt config](#prompt-config)
-   [Options](#options)
-   [Built-in](#built-in)

# Commands

Create custom commands for repetitive tasks.

Custom commands let you specify a prompt you want to run when that command is executed in the TUI.

```
/my-command
```

---

## [Create command files](#create-command-files)

Create markdown files in the `commands/` directory:

.opencode/commands/test.md

```
---
description: Run tests with coverage
agent: build
---

Run the full test suite with coverage report and show any failures.
```

Use the command by typing `/` followed by the command name:

```
/test
```

---

## [Configure](#configure)

### [JSON](#json)

opencode.jsonc

```
{  "$schema": "https://opencode.ai/config.json",  "command": {    "test": {      "template": "Run the full test suite with coverage report.",      "description": "Run tests with coverage",      "agent": "build"    }  }}
```

### [Markdown](#markdown)

Place markdown files in:

-   Global: `~/.config/opencode/commands/`
-   Per-project: `.opencode/commands/`

---

## [Prompt config](#prompt-config)

### [Arguments](#arguments)

Use `$ARGUMENTS` or positional parameters:

.opencode/commands/component.md

```
---
description: Create a new component
---

Create a new React component named $ARGUMENTS with TypeScript support.
```

Run: `/component Button`

You can also use `$1`, `$2`, `$3` for individual arguments.

### [Shell output](#shell-output)

Use *\`command\`* to inject bash command output:

```
Here are the current test results:
`npm test`
```

### [File references](#file-references)

Include files using `@`:

```
Review the component in @src/components/Button.tsx
```

---

## [Options](#options)

-   `template` - **Required**. The prompt sent to the LLM.
-   `description` - Shown in the TUI.
-   `agent` - Which agent should execute this command.
-   `subtask` - Force subagent invocation.
-   `model` - Override the default model.

---

## [Built-in](#built-in)

opencode includes built-in commands like `/init`, `/undo`, `/redo`, `/share`, `/help`.

Note

Custom commands can override built-in commands.

Last updated: Apr 27, 2026
