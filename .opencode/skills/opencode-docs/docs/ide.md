IDE | OpenCode

On this page

-   [Overview](#_top)
-   [Usage](#usage)
-   [Installation](#installation)

# IDE

The OpenCode extension for VS Code, Cursor, and other IDEs

OpenCode integrates with VS Code, Cursor, or any IDE that supports a terminal. Just run `opencode` in the terminal to get started.

---

## [Usage](#usage)

-   **Quick Launch**: Use `Cmd+Esc` (Mac) or `Ctrl+Esc` (Windows/Linux) to open OpenCode in a split terminal view, or focus an existing terminal session if one is already running.
-   **New Session**: Use `Cmd+Shift+Esc` (Mac) or `Ctrl+Shift+Esc` (Windows/Linux) to start a new OpenCode terminal session, even if one is already open.
-   **Context Awareness**: Automatically share your current selection or tab with OpenCode.
-   **File Reference Shortcuts**: Use `Cmd+Option+K` (Mac) or `Alt+Ctrl+K` (Linux/Windows) to insert file references. For example, `@File#L37-42`.

---

## [Installation](#installation)

To install OpenCode on VS Code and popular forks like Cursor, Windsurf, VSCodium:

1.  Open VS Code
2.  Open the integrated terminal
3.  Run `opencode` - the extension installs automatically

If on the other hand you want to use your own IDE when you run `/editor` or `/export` from the TUI, you'll need to set `export EDITOR="code --wait"`. [Learn more](/docs/tui/#editor-setup).

---

### [Manual Install](#manual-install)

Search for **OpenCode** in the Extension Marketplace and click **Install**.

---

### [Troubleshooting](#troubleshooting)

If the extension fails to install automatically:

-   Ensure you're running `opencode` in the integrated terminal.
-   Confirm the CLI for your IDE is installed:
    -   For VS Code: `code` command
    -   For Cursor: `cursor` command
    -   For Windsurf: `windsurf` command
    -   For VSCodium: `codium` command
-   Ensure VS Code has permission to install extensions

Last updated: Apr 27, 2026
