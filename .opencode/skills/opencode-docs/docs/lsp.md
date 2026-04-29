LSP Servers | OpenCode

On this page

-   [Overview](#_top)
-   [Built-in](#built-in)
-   [How It Works](#how-it-works)
-   [Configure](#configure)

# LSP Servers

OpenCode integrates with your Language Server Protocol (LSP) to help the LLM interact with your codebase.

---

## [Built-in](#built-in)

OpenCode comes with several built-in LSP servers:

| LSP Server | Extensions | Requirements |
|------------|------------|-------------|
| typescript | .ts, .tsx, .js, .jsx | `typescript` dependency |
| pyright | .py, .pyi | `pyright` dependency |
| gopls | .go | `go` command available |
| rust | .rs | `rust-analyzer` command |
| deno | .ts, .tsx, .js, .jsx | `deno` command |
| eslint | .ts, .tsx, .js, .jsx | `eslint` dependency |
| vue | .vue | Auto-installed |
| svelte | .svelte | Auto-installed |
| astro | .astro | Auto-installed |
| bash | .sh, .bash, .zsh | Auto-installed |
| clangd | .c, .cpp, .h, .hpp | Auto-installed |
| and more... | | |

LSP servers are automatically enabled when file extensions are detected and requirements are met.

Note

You can disable automatic LSP server downloads by setting `OPENCODE_DISABLE_LSP_DOWNLOAD=true`.

---

## [How It Works](#how-it-works)

When opencode opens a file, it:

1.  Checks the file extension against all enabled LSP servers.
2.  Starts the appropriate LSP server if not already running.

---

## [Configure](#configure)

You can customize LSP servers through the `lsp` section in your config:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "lsp": {}}
```

### [Environment variables](#environment-variables)

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "lsp": {    "rust": {      "env": {        "RUST_LOG": "debug"      }    }  }}
```

### [Initialization options](#initialization-options)

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "lsp": {    "typescript": {      "initialization": {        "preferences": {          "importModuleSpecifierPreference": "relative"        }      }    }  }}
```

### [Disabling LSP servers](#disabling-lsp-servers)

To disable **all** LSP servers:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "lsp": false}
```

To disable a **specific** LSP server:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "lsp": {    "typescript": {      "disabled": true    }  }}
```

### [Custom LSP servers](#custom-lsp-servers)

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "lsp": {    "custom-lsp": {      "command": ["custom-lsp-server", "--stdio"],      "extensions": [".custom"]    }  }}
```

---

## [Additional Information](#additional-information)

### [PHP Intelephense](#php-intelephense)

Place your license key in:

-   macOS/Linux: `$HOME/intelephense/license.txt`
-   Windows: `%USERPROFILE%/intelephense/license.txt`

Last updated: Apr 27, 2026
