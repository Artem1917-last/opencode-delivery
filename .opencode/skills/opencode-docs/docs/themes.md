Themes | OpenCode

On this page

-   [Overview](#_top)
-   [Terminal requirements](#terminal-requirements)
-   [Built-in themes](#built-in-themes)
-   [System theme](#system-theme)
-   [Using a theme](#using-a-theme)
-   [Custom themes](#custom-themes)

# Themes

Select a built-in theme or define your own.

By default, OpenCode uses our own `opencode` theme.

---

## [Terminal requirements](#terminal-requirements)

For themes to display correctly, your terminal must support **truecolor** (24-bit color).

-   **Check support**: Run `echo $COLORTERM` - it should output `truecolor` or `24bit`
-   **Enable truecolor**: Set `COLORTERM=truecolor`

---

## [Built-in themes](#built-in-themes)

| Name | Description |
|------|-------------|
| `system` | Adapts to your terminal's background color |
| `tokyonight` | Based on the Tokyonight theme |
| `everforest` | Based on the Everforest theme |
| `ayu` | Based on the Ayu dark theme |
| `catppuccin` | Based on the Catppuccin theme |
| `catppuccin-macchiato` | Based on the Catppuccin theme |
| `gruvbox` | Based on the Gruvbox theme |
| `kanagawa` | Based on the Kanagawa theme |
| `nord` | Based on the Nord theme |
| `matrix` | Hacker-style green on black |
| `one-dark` | Based on the Atom One Dark theme |

---

## [System theme](#system-theme)

The `system` theme automatically adapts to your terminal's color scheme:

-   **Generates gray scale** based on your terminal's background
-   **Uses ANSI colors** for syntax highlighting
-   **Preserves terminal defaults**

---

## [Using a theme](#using-a-theme)

Select a theme with `/theme` command or in `tui.json`:

tui.json

```
{  "$schema": "https://opencode.ai/tui.json",  "theme": "tokyonight"}
```

---

## [Custom themes](#custom-themes)

### [Hierarchy](#hierarchy)

Themes are loaded from:

1.  **Built-in themes** - Embedded in the binary
2.  **User config** - `~/.config/opencode/themes/*.json`
3.  **Project root** - `<project-root>/.opencode/themes/*.json`
4.  **Current working directory** - `./.opencode/themes/*.json`

### [Creating a theme](#creating-a-theme)

Create a JSON file in one of the theme directories.

### [JSON format](#json-format)

Themes support:

-   **Hex colors**: `"#ffffff"`
-   **ANSI colors**: `3` (0-255)
-   **Color references**: `"primary"`
-   **Dark/light variants**: `{"dark": "#000", "light": "#fff"}`
-   **No color**: `"none"`

### [Example](#example)

my-theme.json

```
{  "$schema": "https://opencode.ai/theme.json",  "defs": {    "nord0": "#2E3440",    "nord4": "#D8DEE9"  },  "theme": {    "primary": {      "dark": "nord8",      "light": "nord10"    },    "text": {      "dark": "nord4",      "light": "nord0"    },    "background": {      "dark": "nord0",      "light": "nord6"    }  }}
```

Last updated: Apr 27, 2026
