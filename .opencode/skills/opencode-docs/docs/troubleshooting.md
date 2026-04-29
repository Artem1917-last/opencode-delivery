Troubleshooting | OpenCode

On this page

-   [Overview](#_top)
-   [Logs](#logs)
-   [Storage](#storage)
-   [Desktop app](#desktop-app)
-   [Getting help](#getting-help)
-   [Common issues](#common-issues)

# Troubleshooting

Common issues and how to resolve them.

To debug issues with OpenCode, start by checking the logs and local data it stores on disk.

---

## [Logs](#logs)

Log files are written to:

-   **macOS/Linux**: `~/.local/share/opencode/log/`
-   **Windows**: Press `WIN+R` and paste `%USERPROFILE%\.local\share\opencode\log`

Log files are named with timestamps (e.g., `2025-01-09T123456.log`) and the most recent 10 log files are kept.

You can set the log level with the `--log-level` command-line option to get more detailed debug information. For example, `opencode --log-level DEBUG`.

---

## [Storage](#storage)

opencode stores session data and other application data on disk at:

-   **macOS/Linux**: `~/.local/share/opencode/`
-   **Windows**: Press `WIN+R` and paste `%USERPROFILE%\.local\share\opencode`

This directory contains:

-   `auth.json` - Authentication data like API keys, OAuth tokens
-   `log/` - Application logs
-   `project/` - Project-specific data like session and message data

---

## [Desktop app](#desktop-app)

OpenCode Desktop runs a local OpenCode server (the `opencode-cli` sidecar) in the background. Most issues are caused by a misbehaving plugin, a corrupted cache, or a bad server setting.

### [Quick checks](#quick-checks)

-   Fully quit and relaunch the app.
-   If the app shows an error screen, click **Restart** and copy the error details.
-   macOS only: `OpenCode` menu -> **Reload Webview** (helps if the UI is blank/frozen).

### [Disable plugins](#disable-plugins)

If the desktop app is crashing on launch, hanging, or behaving strangely, start by disabling plugins.

Open your global config file and look for a `plugin` key. If you have plugins configured, temporarily disable them by removing the key or setting it to an empty array.

### [Clear the cache](#clear-the-cache)

If disabling plugins doesn't help, clear the cache so OpenCode can rebuild it.

1.  Quit OpenCode Desktop completely.
2.  Delete the cache directory:
    -   **macOS**: `~/.cache/opencode`
    -   **Linux**: `~/.cache/opencode`
    -   **Windows**: `%USERPROFILE%\.cache\opencode`
3.  Restart OpenCode Desktop.

### [Windows: WebView2 runtime](#windows-webview2-runtime)

On Windows, OpenCode Desktop requires the Microsoft Edge **WebView2 Runtime**. If the app opens to a blank window or won't start, install/update WebView2 and try again.

### [Windows: General performance issues](#windows-general-performance-issues)

If you're experiencing slow performance, file access issues, or terminal problems on Windows, try using [WSL (Windows Subsystem for Linux)](/docs/windows-wsl).

---

## [Getting help](#getting-help)

If you're experiencing issues with OpenCode:

1.  **Report issues on GitHub** - [**github.com/anomalyco/opencode/issues**](https://github.com/anomalyco/opencode/issues)
2.  **Join our Discord** - [**opencode.ai/discord**](https://opencode.ai/discord)

---

## [Common issues](#common-issues)

### [OpenCode won't start](#opencode-wont-start)

1.  Check the logs for error messages
2.  Try running with `--print-logs` to see output in the terminal
3.  Ensure you have the latest version with `opencode upgrade`

### [Authentication issues](#authentication-issues)

1.  Try re-authenticating with the `/connect` command in the TUI
2.  Check that your API keys are valid
3.  Ensure your network allows connections to the provider's API

### [Model not available](#model-not-available)

1.  Check that you've authenticated with the provider
2.  Verify the model name in your config is correct
3.  Some models may require specific access or subscriptions

If you encounter `ProviderModelNotFoundError` you are most likely incorrectly referencing a model somewhere. Models should be referenced like so: `<providerId>/<modelId>`

### [ProviderInitError](#provideriniterror)

If you encounter a ProviderInitError, you likely have an invalid or corrupted configuration.

To resolve this:

1.  First, verify your provider is set up correctly
2.  If the issue persists, try clearing your stored configuration
3.  Re-authenticate with your provider using the `/connect` command in the TUI.

### [Copy/paste not working on Linux](#copypaste-not-working-on-linux)

Linux users need to have one of the following clipboard utilities installed for copy/paste functionality to work:

**For X11 systems:**

```
apt install -y xclip
```

**For Wayland systems:**

```
apt install -y wl-clipboard
```

Last updated: Apr 27, 2026
