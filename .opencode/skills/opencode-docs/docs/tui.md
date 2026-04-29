TUI | OpenCode

On this page

-   [Overview](#_top)
-   [File references](#file-references)
-   [Bash commands](#bash-commands)
-   [Commands](#commands)
-   [Editor setup](#editor-setup)
-   [Configure](#configure)
-   [Customization](#customization)

# TUI

Using the OpenCode terminal user interface.

OpenCode provides an interactive terminal interface or TUI for working on your projects with an LLM.

Running OpenCode starts the TUI for the current directory.

Terminal window

```
opencode
```

Or you can start it for a specific working directory.

Terminal window

```
opencode /path/to/project
```

---

## [File references](#file-references)

You can reference files in your messages using `@`. This does a fuzzy file search in the current working directory.

```
How is auth handled in @packages/functions/src/api/index.ts?
```

The content of the file is added to the conversation automatically.

---

## [Bash commands](#bash-commands)

Start a message with `!` to run a shell command.

```
!ls -la
```

The output of the command is added to the conversation as a tool result.

---

## [Commands](#commands)

When using the OpenCode TUI, you can type `/` followed by a command name to quickly execute actions.

Here are all available slash commands:

-   `/connect` - Add a provider to OpenCode
-   `/compact` - Compact the current session. *Alias*: `/summarize`
-   `/details` - Toggle tool execution details
-   `/editor` - Open external editor for composing messages
-   `/exit` - Exit OpenCode. *Aliases*: `/quit`, `/q`
-   `/export` - Export current conversation to Markdown
-   `/help` - Show the help dialog
-   `/init` - Guided setup for creating or updating `AGENTS.md`
-   `/models` - List available models
-   `/new` - Start a new session. *Alias*: `/clear`
-   `/redo` - Redo a previously undone message
-   `/sessions` - List and switch between sessions. *Aliases*: `/resume`, `/continue`
-   `/share` - Share current session
-   `/themes` - List available themes
-   `/thinking` - Toggle visibility of thinking/reasoning blocks
-   `/undo` - Undo last message in the conversation
-   `/unshare` - Unshare current session

---

## [Editor setup](#editor-setup)

Both the `/editor` and `/export` commands use the editor specified in your `EDITOR` environment variable.

**Linux/macOS:**

```
export EDITOR=vim
# For GUI editors, include --wait
export EDITOR="code --wait"
```

**Windows (PowerShell):**

```
$env:EDITOR = "notepad"
$env:EDITOR = "code --wait"
```

Popular editor options include:

-   `code` - Visual Studio Code
-   `cursor` - Cursor
-   `nvim` - Neovim editor
-   `vim` - Vim editor
-   `nano` - Nano editor
-   `notepad` - Windows Notepad

Note

Some editors like VS Code need to be started with the `--wait` flag.

---

## [Configure](#configure)

You can customize TUI behavior through `tui.json` (or `tui.jsonc`).

tui.json

```
{  "$schema": "https://opencode.ai/tui.json",  "theme": "opencode",  "keybinds": {    "leader": "ctrl+x"  },  "scroll_speed": 3,  "scroll_acceleration": {    "enabled": true  },  "diff_style": "auto",  "mouse": true}
```

### [Options](#options)

-   `theme` - Sets your UI theme. [Learn more](/docs/themes).
-   `keybinds` - Customizes keyboard shortcuts. [Learn more](/docs/keybinds).
-   `scroll_acceleration.enabled` - Enable macOS-style scroll acceleration.
-   `scroll_speed` - Controls how fast the TUI scrolls (minimum: `0.001`). Defaults to `3`.
-   `diff_style` - Controls diff rendering. `"auto"` adapts to terminal width, `"stacked"` always shows single-column.
-   `mouse` - Enable or disable mouse capture in the TUI (default: `true`).

Use `OPENCODE_TUI_CONFIG` to load a custom TUI config path.

---

## [Customization](#customization)

You can customize various aspects of the TUI view using the command palette (`ctrl+x h` or `/help`).

#### [Username display](#username-display)

Toggle whether your username appears in chat messages. The setting persists automatically across TUI sessions.

Last updated: Apr 27, 2026
