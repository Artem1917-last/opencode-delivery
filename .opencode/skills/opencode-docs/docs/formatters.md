Formatters | OpenCode

On this page

-   [Overview](#_top)
-   [Built-in](#built-in)
-   [How it works](#how-it-works)
-   [Configure](#configure)

# Formatters

OpenCode uses language specific formatters.

OpenCode automatically formats files after they are written or edited using language-specific formatters.

---

## [Built-in](#built-in)

OpenCode comes with several built-in formatters:

| Formatter | Extensions | Requirements |
|-----------|------------|-------------|
| biome | .js, .jsx, .ts, .tsx, .html, .css, .md, .json | `biome.json(c)` config |
| prettier | .js, .jsx, .ts, .tsx, .html, .css, .md, .json | `prettier` in package.json |
| ruff | .py, .pyi | `ruff` command available |
| gofmt | .go | `gofmt` command available |
| rustfmt | .rs | `rustfmt` command available |
| clang-format | .c, .cpp, .h, .hpp | `.clang-format` config |
| dart | .dart | `dart` command available |
| shfmt | .sh, .bash | `shfmt` command available |
| terraform | .tf, .tfvars | `terraform` command available |
| and more... | | |

If your project has the formatter's dependency, OpenCode will automatically use it.

---

## [How it works](#how-it-works)

When OpenCode writes or edits a file, it:

1.  Checks the file extension against all enabled formatters.
2.  Runs the appropriate formatter command on the file.
3.  Applies the formatting changes automatically.

---

## [Configure](#configure)

You can customize formatters through the `formatter` section in your config.

### [Disabling formatters](#disabling-formatters)

To disable **all** formatters:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "formatter": false}
```

To disable a **specific** formatter:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "formatter": {    "prettier": {      "disabled": true    }  }}
```

### [Custom formatters](#custom-formatters)

You can override built-in formatters or add new ones:

opencode.json

```
{  "$schema": "https://opencode.ai/config.json",  "formatter": {    "custom-prettier": {      "command": ["npx", "prettier", "--write", "$FILE"],      "extensions": [".js", ".ts", ".jsx", ".tsx"]    }  }}
```

The `$FILE` placeholder will be replaced with the path to the file being formatted.

Last updated: Apr 27, 2026
