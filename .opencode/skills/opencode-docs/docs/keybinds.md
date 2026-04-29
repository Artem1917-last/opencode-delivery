Keybinds | OpenCode

On this page

-   [Overview](#_top)
-   [Leader key](#leader-key)
-   [Disable keybind](#disable-keybind)
-   [Desktop prompt shortcuts](#desktop-prompt-shortcuts)
-   [Shift+Enter](#shiftenter)

# Keybinds

Customize your keybinds.

OpenCode has a list of keybinds that you can customize through `tui.json`.

tui.json

```
{  "$schema": "https://opencode.ai/tui.json",  "keybinds": {    "leader": "ctrl+x",    "app_exit": "ctrl+c,ctrl+d,<leader>q",    "session_new": "<leader>n",    "session_list": "<leader>l",    "model_list": "<leader>m",    "input_submit": "return",    "input_newline": "shift+return,ctrl+return"  }}
```

---

## [Leader key](#leader-key)

OpenCode uses a `leader` key for most keybinds. By default, `ctrl+x` is the leader key.

For example, to start a new session you first press `ctrl+x` and then press `n`.

---

## [Disable keybind](#disable-keybind)

You can disable a keybind by setting it to "none":

tui.json

```
{  "$schema": "https://opencode.ai/tui.json",  "keybinds": {    "session_compact": "none"  }}
```

---

## [Desktop prompt shortcuts](#desktop-prompt-shortcuts)

| Shortcut | Action |
|----------|--------|
| `ctrl+a` | Move to start of line |
| `ctrl+e` | Move to end of line |
| `ctrl+b` | Move cursor back one character |
| `ctrl+f` | Move cursor forward one character |
| `alt+b` | Move cursor back one word |
| `alt+f` | Move cursor forward one word |
| `ctrl+d` | Delete character under cursor |
| `ctrl+k` | Kill to end of line |
| `ctrl+u` | Kill to start of line |
| `ctrl+w` | Kill previous word |
| `ctrl+t` | Transpose characters |
| `ctrl+g` | Cancel popovers / abort running response |

---

## [Shift+Enter](#shiftenter)

Some terminals don't send modifier keys with Enter by default.

### [Windows Terminal](#windows-terminal)

Add to your `settings.json`:

```
"actions": [  {    "command": {      "action": "sendInput",      "input": "\u001b[13;2u"    },    "id": "User.sendInput.ShiftEnterCustom"  }],
"keybindings": [  {    "keys": "shift+enter",    "id": "User.sendInput.ShiftEnterCustom"  }]
```

Last updated: Apr 27, 2026
